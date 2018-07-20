describe Fastlane::Actions::DownloadBcsymbolmapsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The buddybuild_bcsymbolmaps plugin is working!")
      json = '{"build_number": 1000, "links": {"download": [{"name": "SomeApp", "url": "https://downloads.buddybuild.com/api/download/download-ipa?buildID=5b4d175dba4320001c8376a"}]}}'

      Fastlane::Actions::DownloadBcsymbolmapsAction.run(json: json)
    end
  end
end
