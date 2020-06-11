module Applitools
  module Selenium
    class IRenderBrowserInfo < ::Applitools::AbstractConfiguration

      object_field :viewport_size, Applitools::RectangleSize
      enum_field :browser_type, BrowserTypes.enum_values
      string_field :platform
      string_field :size_mode
      string_field :baseline_env_name

      def to_s
        return "#{viewport_size} (#{browser_type})"
      end
    end
  end
end