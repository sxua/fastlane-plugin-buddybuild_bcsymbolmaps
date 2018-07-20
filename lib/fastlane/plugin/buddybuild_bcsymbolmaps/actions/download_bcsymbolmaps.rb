require 'fastlane/action'

module Fastlane
  module Actions
    class DownloadBcsymbolmapsAction < Action
      def self.run(params)
        require 'json'
        require 'zip'

        json = JSON.parse(params[:json])
        build_number = json["build_number"]
        url = json["links"]["download"].first["url"].gsub("download-ipa", "download-itc-ipa")
        destination_path = File.join(Dir.pwd, "fastlane", "BCSymbolMaps")

        prepare_destination_path(destination_path)
        zip_path = download_file_with_prompt(url, build_number)
        extract_zip(zip_path)

        build_number.to_s
      end

      def self.description
        "Download BCSymbolMaps from buddybuild before uploading to a crash reporting tool."
      end

      def self.authors
        ["sxua"]
      end

      def self.return_value
        "Build number"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :json,
                                  env_name: "BUDDYBUILD_BCSYMBOLMAPS_JSON",
                               description: "JSON Response from buddybuild",
                                  optional: false,
                              verify_block: proc do |value|
                                UI.user_error!("No JSON response for download_bcsymbolmaps action given, pass using `json: json_response`") unless value
                              end)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
      
      def self.extract_zip(file)
        Zip::File.open(file) do |zip_file|
          zip_file.glob("BCSymbolMaps/*.bcsymbolmap").each do |f|
            fpath = File.join(Dir.pwd, "fastlane", f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
      
      def self.download_file_with_prompt(url, build_number)
        file_path = File.join(Dir.pwd, "BCSymbolMaps-#{build_number}.zip")

        if File.exists?(file_path)
          if UI.confirm("File at #{file_path} is already exists. Do you want to overwrite it?")
            UI.verbose("Overwriting an already exisiting file at #{file_path}")
            File.rm(file_path)
            self.download_file(url, file_path)
          else
            UI.verbose("Skipping download")
          end
        else
          UI.message("Downloading a BCSymbolMaps")
          self.download_file(url, file_path)
        end

        file_path
      end

      def self.download_file(url, file_path)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        res = http.get(uri.request_uri)
        File.binwrite(file_path, res.body)
      end

      def self.prepare_destination_path(destination_path)
        if Dir.exists?(destination_path)
          FileUtils.rm_r(destination_path)
        end
        FileUtils.mkdir_p(destination_path)
      end
    end
  end
end
