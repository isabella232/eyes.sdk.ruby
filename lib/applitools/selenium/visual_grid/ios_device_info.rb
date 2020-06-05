require_relative 'ios_device_name'
require_relative 'ios_screen_orientation'
module Applitools
  module Selenium
    class IosDeviceInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
            platform: 'ios',
            browser_type: BrowserTypes::IOS_SAFARI,
            # size_mode: 'full-page',
            viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end
      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end


      def initialize(options = {})
        super()
        self.ios_device_info = EmulationInfo.new.tap do |ei|
          ei.device_name = options[:device_name]
          ei.screen_orientation = options[:screen_orientation] || IosScreenshotOrientations::PORTRAIT
        end
      end

      private

      class EmulationInfo < EmulationBaseInfo
        enum_field :device_name, IosDeviceName.enum_values
        enum_field :screen_orientation, IosScreenshotOrientations.enum_values

        def json_data
          {
              name: device_name,
              screenOrientation: screen_orientation,
              version: 'latest'
          }
        end
      end
    end
  end
end