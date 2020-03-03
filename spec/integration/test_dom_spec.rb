# frozen_string_literal: true
require 'spec_helper'
require_relative 'test_utils'

RSpec.describe 'TestSendDom' do
  class DomInterceptingEyes < Applitools::Selenium::SeleniumEyes
    attr_accessor :dom_json
    def dom_data
      self.dom_json = super
    end
  end

  def get_has_dom_(api_key, results)
    session_results = TestUtils.get_session_results(api_key, results)
    actual_app_outputs = session_results['actualAppOutput']
    expect(actual_app_outputs.length).to eq 1
    actual_app_outputs[0]['image']['hasDom']
  end

  let(:web_driver) { Selenium::WebDriver.for :chrome }
  let(:eyes_web_driver) do |example|
    eyes.open(
      driver: web_driver,
      app_name: 'Test Send DOM',
      test_name: example.description,
      viewport_size: { width: 1024, height: 768 }
    )
  end

  context 'DomInterceptingEyes' do
    let(:eyes) { DomInterceptingEyes.new }
    it 'TestSendDOM_FullWindow' do
      eyes_web_driver.get('https://applitools.github.io/demo/TestPages/FramesTestPage/')

      begin
        eyes.check('window', Applitools::Selenium::Target.window.fully)
        actual_dom_json_string = Oj.load(eyes.dom_json)
        expected_dom_json = Oj.load(
            File.read(
                File.join(File.dirname(__FILE__ ),'/../fixtures/expected_dom1.json')
            )
        )
        results = eyes.close(false)
        has_dom = get_has_dom_(eyes.api_key, results)
        # expect(actual_dom_json_string).to eq expected_dom_json
        expect(has_dom).to be_truthy

        session_results = TestUtils.get_session_results(eyes.api_key, results)
        actual_app_outputs = session_results['actualAppOutput']
        downloaded_dom_json = TestUtils.get_step_dom(eyes, actual_app_outputs[0])
        expect(downloaded_dom_json).to eq actual_dom_json_string
      ensure
        eyes.abort
        web_driver.quit
      end
    end
  end

  it 'TestSendDOM_Simple_HTML'
  it 'TestSendDOM_Selector'
  it 'TestNotSendDOM'
  it 'TestSendDOM_1'
  it 'TestSendDOM_2'
end