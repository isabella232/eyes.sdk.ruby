require 'spec_helper'

RSpec.describe 'Selenium' do
  before(:each) { eyes.accessibility_validation = Applitools::Selenium::AccessibilityLevel::AAA }

  describe 'Accessibility', selenium: true do
    let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/FramesTestPage/' }
    let(:target) do
      Applitools::Selenium::Target.window.accessibility(
          :css, '.ignore',
          type: Applitools::Selenium::AccessibilityRegionType::GRAPHICAL_OBJECT
      )
    end

    it 'TestAccessibilityRegions' do
      eyes.check('step1', target)
      add_expected_property('accessibilityLevel', Applitools::Selenium::AccessibilityLevel::AAA)
    end
  end
end