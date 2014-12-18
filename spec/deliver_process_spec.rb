describe Deliver do
  describe Deliver::DeliverProcess do

    describe "fetch information from ipa file" do

      before(:each) do
        @version = '1.0'
        @identifier = 'at.felixkrause.iTanky'
        @ipa = "spec/fixtures/ipas/Example1.ipa"
      end

      context "loads app_identifier from Appfile if existing" do
        let (:app_identifier) { 'net.sunapps.54' }
        before(:each) do
          @app_file = File.join(Dir.pwd, "Appfile") 
          File.write(@app_file, "app_identifier '#{app_identifier}'")
          @process = Deliver::DeliverProcess.new({version: '1.0'})

          expect {
            @process.run # this will then fetch the app identifier from the app config
          }.to raise_error "You have to set a mock file for this test!"
        end

        it "uses the given app identifier" do
          expect(@process.app_identifier).to eq(app_identifier)
        end

        after(:each) do
          File.delete(@app_file)
        end
      end

      context "when there's a beta build defined" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: true,
            beta_ipa: beta_ipa,
            skip_deploy: false,
          })

          @process.fetch_information_from_ipa_file
        end

        it "uploads a beta build" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_BETA_BUILD
        end
      end

      context "when there's no beta build defined" do

        before(:each) do
          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: false,
            skip_deploy: false,
            ipa: @ipa
          })

          @process.fetch_information_from_ipa_file
        end

        it "uploads a build to the app store" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_APP_STORE
        end
      end

      context "when there's no beta build defined but deployment should be skipped" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: false,
            ipa: @ipa,
            skip_deploy: true,
          })

          @process.fetch_information_from_ipa_file
        end

        it "skips deployment" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
        end
      end

      context "when there's a beta build defined but deployment should be skipped" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: true,
            beta_ipa: beta_ipa,
            skip_deploy: true,
          })

          @process.fetch_information_from_ipa_file
        end

        it "skips deployment" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
        end
      end
    end
  end
end
