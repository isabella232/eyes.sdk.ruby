RSpec.describe Applitools::EyesBaseConfiguration do
  context 'ignore_displacements' do
    it_should_behave_like 'responds to method', [:ignore_displacements, :ignore_displacements=]
    it 'default value' do
      expect(subject.default_match_settings.ignore_displacements).to be false
    end

    it 'passes value to image_match_settings' do
      subject.ignore_displacements = false
      expect(subject.default_match_settings.ignore_displacements).to be false
      subject.ignore_displacements = true
      expect(subject.default_match_settings.ignore_displacements).to be true
      subject.ignore_displacements = false
      expect(subject.default_match_settings.ignore_displacements).to be false
    end
  end
end