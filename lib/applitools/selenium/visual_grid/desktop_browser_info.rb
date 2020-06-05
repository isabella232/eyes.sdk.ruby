# frozen_string_literal: true
require 'applitools/selenium/browser_types'

module Applitools
  module Selenium
    class DesktopBrowserInfo < IRenderBrowserInfo
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

      def initialize(options = {})
        super()
        if options[:width] && options[:height]
          self.viewport_size = Applitools::RectangleSize.from_any_argument(width: options[:width], height: options[:height])
        end
        self.browser_type = options[:browser_type] if options[:browser_type]
      end

      def platform
        case browser_type
        when BrowserTypes::EDGE_LEGACY, BrowserTypes::EDGE_CHROMIUM, BrowserTypes::EDGE_CHROMIUM_ONE_VERSION_BACK
          'windows'
        else
          'linux'
        end
      end

    end
  end
end

Applitools::Selenium::RenderBrowserInfo = Applitools::Selenium::DesktopBrowserInfo
