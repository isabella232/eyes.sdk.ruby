# frozen_string_literal: true
require_relative 'emulation_base_info'
require_relative 'i_render_browser_info'
module Applitools
  module Selenium
    class ChromeEmulationInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
            platform: 'linux',
            browser_type: BrowserTypes::CHROME,
            # size_mode: 'full-page',
            viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end
      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end

      # def device_name
      #   emulation_info.device_name
      # end
      #
      def initialize(*args)
        super()
        case args[0]
        when String
          self.emulation_info = EmulationInfo.new.tap do |ei|
            ei.device_name = args[0]
            ei.screen_orientation = args[1] || Orientations::PORTRAIT
          end
        when Hash
          self.emulation_info = EmulationInfo.new.tap do |ei|
            ei.device_name = args[0][:device_name]
            ei.screen_orientation = args[0][:screen_orientation] || Orientations::PORTRAIT
          end
        end
      end

      private

      class EmulationInfo < Applitools::Selenium::EmulationBaseInfo
        enum_field :device_name, Devices.enum_values
        enum_field :screen_orientation, Orientations.enum_values

        def json_data
          {
              :'deviceName' => device_name,
              :'screenOrientation' => screen_orientation
          }
        end
      end
    end
  end
end
