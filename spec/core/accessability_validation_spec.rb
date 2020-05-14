OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
RSpec.describe 'AccessibilityValidation' do
  context 'accessibility_settings' do
    let(:valid) do
      Applitools::AccessibilitySettings.new(
        Applitools::AccessibilityLevel::AA,
        Applitools::AccessibilityVersion::WCAG_2_0
      )
    end

    it 'returns hash' do
      expect(valid).to respond_to :to_h
      expect(valid.to_h[:level]).to eq 'AA'
      expect(valid.to_h[:version]).to eq 'WCAG_2_0'
    end

    it 'responds_to :json_data' do
      expect(valid).to respond_to(:json_data)
    end

    it 'rejects wrong values' do
      expect { Applitools::AccessibilitySettings.new('BBB', 'WCAG_2_0') }.to(
        raise_error(
          Applitools::EyesIllegalArgument
        )
      )
      expect { Applitools::AccessibilitySettings.new('AAA', 'BLAH') }.to(
          raise_error(Applitools::EyesIllegalArgument)
      )
    end

    it 'accepts allowed values' do
      expect { Applitools::AccessibilitySettings.new('AA', 'WCAG_2_0')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AAA', 'WCAG_2_0')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AA', 'WCAG_2_1')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AAA', 'WCAG_2_1')}.to_not raise_error
    end
  end
  context 'ImageMatchSettings' do
    subject { Applitools::ImageMatchSettings.new }
    let(:as) { Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityVersion::WCAG_2_0) }
    it 'accepts nil value for :accessibility_validation=' do
      expect { subject.accessibility_validation = nil }.to_not raise_error
    end
    it 'accepts Applitools::AccessibilitySettings for :accessibility_validation=' do
      expect { subject.accessibility_validation = as }.to_not raise_error
    end
    it 'rejects wrong type for :accessibility_validation=' do
      expect { subject.accessibility_validation = Struct.new(:accessibility_level) }.to raise_error Applitools::EyesIllegalArgument
    end
    context 'json' do
      it 'has :accessibilitySettings property' do
        expect(subject.json_data.keys).to include(:accessibilitySettings)
      end
      it ':accessibilitySettings value' do
        subject.accessibility_validation = as
        expect(subject.json_data[:accessibilitySettings]).to be_a Hash
        expect(subject.json_data[:accessibilitySettings][:level]).to eq(as.level)
        expect(subject.json_data[:accessibilitySettings][:version]).to eq(as.version)
      end
    end
  end
  context 'AccessibilitySettings' do
    shared_examples 'has_accessibility_settings' do
      it ('accessibility related methods') do
        expect(config).to respond_to :accessibility_validation
        expect(config).to respond_to :accessibility_validation=
        expect(config.default_match_settings).to respond_to(:accessibility_validation)
        expect(config.default_match_settings).to respond_to(:accessibility_validation=)
        expect(config.default_match_settings.accessibility_validation).to be nil
      end
      it 'sets :accessibility_settings' do
        expect(config.default_match_settings.accessibility_settings).to be nil
        ac = Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AAA, Applitools::AccessibilityVersion::WCAG_2_0)
        config.accessibility_validation = ac
        expect(config.default_match_settings.accessibility_settings).to be_a(Applitools::AccessibilitySettings)
        expect(config.default_match_settings.accessibility_settings.level).to eq ac.level
        expect(config.default_match_settings.accessibility_settings.version).to eq ac.version
      end
    end
    context 'Core' do
      let(:config) { Applitools::EyesBaseConfiguration.new }
      it_behaves_like 'has_accessibility_settings'
    end
    context 'Selenium' do
      let(:config) { Applitools::Selenium::Configuration.new }
      it_behaves_like 'has_accessibility_settings'
    end
  end
  context 'integration' do
    let(:eyes) do
      result = Applitools::Selenium::Eyes.new
      result.configure do |c|
        c.server_url = 'https://testeyesapi.applitools.com'
        c.accessibility_validation = Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityVersion::WCAG_2_0)
        c.set_proxy('http://localhost:8000')
        c.match_level = Applitools::MatchLevel::STRICT
      end
      result
    end
    let(:web_driver) { Selenium::WebDriver.for :chrome }
    let(:driver) do
      eyes.open(
        app_name: 'SessionStartInfo',
        test_name: 'classic',
        viewport_size: { width: 800, height: 600 },
        driver: web_driver
      )
    end

    let(:driver1) do
      eyes.open(
          app_name: 'SessionStartInfo',
          test_name: 'classic',
          viewport_size: { width: 800, height: 600 },
          driver: web_driver
      )
    end

    let(:driver2) do
      eyes.open(
          app_name: 'SessionStartInfo',
          test_name: 'Accessibility regions',
          viewport_size: { width: 800, height: 600 },
          driver: web_driver
      )
    end

    def eyes_test_result()
      @eyes_test_result
    end

    def session_results()
      Oj.load(Net::HTTP.get(session_results_url))
    end

    def session_query_params
      URI.encode_www_form('AccessToken' => eyes_test_result.secret_token, 'apiKey' => eyes.api_key, 'format' => 'json')
    end

    def session_results_url
      url = URI.parse(eyes_test_result.api_session_url)
      url.query = session_query_params
      url
    end

    it 'check' do
      driver.get('https://applitools.com/helloworld')
      eyes.check('Blah', Applitools::Selenium::Target.window())
      @eyes_test_result = eyes.close
      expect(@eyes_test_result.passed?).to be_truthy
      expect(session_results['startInfo']['defaultMatchSettings']['accessibilitySettings']).to eq({'level' => 'AA', 'version' => 'WCAG_2_0'})

      eyes.configure do |c|
        c.accessibility_validation = nil
      end

      driver1.get('https://applitools.com/helloworld')
      eyes.check('Blah', Applitools::Selenium::Target.window())
      @eyes_test_result = eyes.close
      expect(@eyes_test_result.passed?).to be_truthy
      expect(session_results['startInfo']['defaultMatchSettings']['accessibilitySettings']).to be nil

      driver.quit
    end

    it 'check regions' do
      driver2.get('https://demo.applitools.com/')
      eyes.check(
        'Accessibility regions',
        Applitools::Selenium::Target.window
            .accessibility(:css, 'input', type: Applitools::AccessibilityRegionType::IGNORE_CONTRAST)
            # .accessibility(:css, 'input#password', type: Applitools::AccessibilityRegionType::IGNORE_CONTRAST)
      )
      @eyes_test_result = eyes.close(false)
      local_session_results = session_results
      expect(local_session_results['actualAppOutput'][0]['imageMatchSettings']['accessibility']).to(
        include({'type'=>'IgnoreContrast', 'isDisabled'=>false, 'left'=>255, 'top'=>347, 'width'=>290, 'height'=>37})
      )
      expect(local_session_results['actualAppOutput'][0]['imageMatchSettings']['accessibility']).to(
          include({'type'=>'IgnoreContrast', 'isDisabled'=>false, 'left'=>255, 'top'=>425, 'width'=>290, 'height'=>37})
      )
      driver.quit
    end
  end
end