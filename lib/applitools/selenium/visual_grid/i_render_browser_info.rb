module Applitools
  module Selenium
    class IRenderBrowserInfo < ::Applitools::AbstractConfiguration

      object_field :viewport_size, Applitools::RectangleSize
      enum_field :browser_type, BrowserTypes.enum_values
      string_field :platform
      string_field :size_mode
      string_field :baseline_env_name
      object_field :emulation_info, Applitools::Selenium::EmulationBaseInfo
      object_field :ios_device_info, Applitools::Selenium::EmulationBaseInfo

      def device_name
        return 'desktop' unless emulation_info || ios_device_info
        return ios_device_info.device_name if ios_device_info
        return emulation_info.device_name + ' (chrome emulation)' if emulation_info
      end

      def to_s
        return "#{viewport_size} (#{browser_type})" unless emulation_info
        "#{emulation_info.device_name} - #{emulation_info.screen_orientation}"
      end
    end
  end
end