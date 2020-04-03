RSpec.describe 'Default config values for Selenium' do
  let(:configuration) { Applitools::Selenium::Configuration.new }
  let(:runner) { Applitools::ClassicRunner.new }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
  context 'hide_scrollbars' do
    it 'in configuration' do
      expect(configuration.hide_scrollbars).to be_truthy
    end
    it 'in an Eyes instance' do
      expect(eyes.hide_scrollbars).to be_truthy
    end
  end
end