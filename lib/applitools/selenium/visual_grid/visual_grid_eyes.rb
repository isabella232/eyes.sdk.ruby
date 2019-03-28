module Applitools
  module Selenium
    class VisualGridEyes
      extend Forwardable

      def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

      attr_accessor :visual_grid_manager, :driver, :current_url, :current_config, :fetched_cache_map
      attr_accessor :test_list

      attr_accessor :api_key, :server_url, :proxy, :batch_info, :opened

      def initialize(visual_grid_manager)
        self.visual_grid_manager = visual_grid_manager
        self.test_list = Applitools::Selenium::TestList.new
        self.batch_info = BatchInfo.new
        self.opened = false
      end

      def open(*args)
        self.test_list = Applitools::Selenium::TestList.new
        options = Applitools::Utils.extract_options!(args)
        Applitools::ArgumentGuard.hash(options, 'options', [:driver])

        self.current_config = options.delete(:config)
        self.current_config = yield(Applitools::Selenium::SeleniumConfiguration.new) if block_given?

        # Applitools::ArgumentGuard.is_a? options[:driver], 'options[:driver]', ::Selenium::WebDriver
        Applitools::ArgumentGuard.is_a? current_config, 'options[:config]', Applitools::Selenium::SeleniumConfiguration

        batch_info.name = current_config.app_name
        self.driver = options.delete(:driver)
        self.current_url = driver.current_url

        visual_grid_manager.open(self)

        logger.info("getting all browsers info...")
        browsers_info_list = current_config.browsers_info
        logger.info("creating test descriptors for each browser info...")
        browsers_info_list.each do |bi|
          test_list.push Applitools::Selenium::RunningTest.new(eyes_connector, current_config.deep_clone, bi, driver)
        end
        self.opened = true
        driver
      end

      def eyes_connector
        logger.info("creating VisualGridEyes server connector")
        ::Applitools::Selenium::EyesConnector.new(server_url).tap do |connector|
          connector.batch = batch_info
          # connector.batch = ''
          # connector.branch_name = ''
          # connector.parent_branch_name = ''
          # connector.hide_caret = ''
          # connector.match_level = ''

          # logger.verbose("creating VisualGridEyes server connector");
          # EyesConnector VGEyesConnector = new EyesConnector(browserInfo, renderingGridManager.getRateLimiter());
          # if (browserInfo.getEmulationInfo() != null) {
          #     VGEyesConnector.setDevice(browserInfo.getEmulationInfo().getDeviceName());
          # }
          # VGEyesConnector.setLogHandler(this.logger.getLogHandler());
          # VGEyesConnector.setProxy(this.proxy);
          # VGEyesConnector.setBatch(batchInfo);
          # VGEyesConnector.setBranchName(this.branchName);
          # VGEyesConnector.setParentBranchName(parentBranchName);
          # VGEyesConnector.setHideCaret(this.hideCaret);
          # VGEyesConnector.setMatchLevel(matchLevel);
          # if (serverConnector != null) {
          #     VGEyesConnector.setServerConnector(serverConnector);
          # }
          #
          # URI serverUri = this.getServerUrl();
          # if (serverUri != null) {
          #     VGEyesConnector.setServerUrl(serverUri.toString());
          # }
          #
          # String apiKey = this.getApiKey();
          # if (apiKey != null) {
          #     VGEyesConnector.setApiKey(apiKey);
          # } else {
          #     throw new EyesException("Missing API key");
          # }
          #
          # if (this.renderingInfo == null) {
          #     logger.verbose("initializing rendering info...");
          # this.renderingInfo = VGEyesConnector.getRenderingInfo();
          # }
          # VGEyesConnector.setRenderInfo(this.renderingInfo);
          #
          # this.VGEyesConnector = VGEyesConnector;
          # return VGEyesConnector;
        end
      end

      def check(tag, target)

        script = <<-END
          var callback = arguments[arguments.length - 1]; return (#{Applitools::Selenium::Scripts::PROCESS_RESOURCES})().then(JSON.stringify).then(callback, function(err) {callback(err.stack || err.toString())});
        END

        script_result = driver.execute_async_script(script).freeze
        mod = Digest::SHA2.hexdigest(script_result)
        test_list.each do |test|
          test.check(tag, target, script_result.dup, visual_grid_manager, mod)
        end
        test_list.each { |t| t.becomes_not_rendered}

      end

      def close(throw_exception = true)
        return false if test_list.empty?
        test_list.each do |t|
          t.close
        end

        while (!((states = test_list.map(&:state_name).uniq).count == 1 && states.first == :completed)) do
          sleep 0.5
        end
        self.opened = false

        test_list.select { |t| t.pending_exceptions && !t.pending_exceptions.empty? }.each do |t|
          t.pending_exceptions.each do |e|
            raise e
          end
        end

        if throw_exception
          test_list.map(&:test_result).compact.each do |r|
            raise Applitools::NewTestError.new new_test_error_message(r), r if r.new?
            raise Applitools::DiffsFoundError.new diffs_found_error_message(r), r if r.unresolved? && !r.new?
            raise Applitools::TestFailedError.new test_failed_error_message(r), r if r.failed?
          end
        end
        test_list.map(&:test_result).first
      end

      def open?
        opened
      end

      def get_all_test_results
        test_list.map(&:test_result)
      end

      def new_test_error_message(result)
        original_results = result.original_results
        "New test '#{original_results['name']}' " \
            "of '#{original_results['appName']}' " \
            "Please approve the baseline at #{original_results['appUrls']['session']} "
      end

      def diffs_found_error_message(result)
        original_results = result.original_results
        "Test '#{original_results['name']}' " \
            "of '#{original_results['appname']}' " \
            "detected differences! See details at #{original_results['appUrls']['session']}"
      end

      def test_failed_error_message(result)
        original_results = result.original_results
        "Test '#{original_results['name']}' of '#{original_results['appName']}' " \
            "is failed! See details at #{original_results['appUrls']['session']}"
      end
      private :new_test_error_message, :diffs_found_error_message, :test_failed_error_message
    end
  end
end
