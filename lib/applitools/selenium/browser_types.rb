# frozen_string_literal: true
module BrowserTypes
  extend self
  def const_missing(name)
    puts 'Please, prefer using BrowserType instead of BrowserTypes(plural).'
    BrowserType.const_get(name)
  end

  def enum_values
    BrowserType.enum_values
  end
end
module BrowserType
  extend self
  CHROME = :'chrome-0'
  CHROME_ONE_VERSION_BACK = :'chrome-1'
  CHROME_TWO_VERSIONS_BACK = :'chrome-2'

  FIREFOX = :'firefox-0'
  FIREFOX_ONE_VERSION_BACK = :'firefox-1'
  FIREFOX_TWO_VERSIONS_BACK = :'firefox-2'

  SAFARI = :'safari-0'
  SAFARI_ONE_VERSION_BACK = :'safari-1'
  SAFARI_TWO_VERSIONS_BACK = :'safari-2'
  IOS_SAFARI = :safari

  EDGE_CHROMIUM = :'edgechromium'
  EDGE_CHROMIUM_ONE_VERSION_BACK = :'edgechromium-1'

  IE_11 = :ie
  EDGE_LEGACY = :edgelegacy
  IE_10 = :ie10

  def const_defined?(name)
    return true if name == :EDGE
    super
  end

  def const_missing(name)
    if name == :EDGE
      Applitools::EyesLogger.warn(
        'The \'EDGE\' option that is being used in your browsers\' configuration will soon be deprecated. ' \
        'Please change it to either \'EDGE_LEGACY\' for the legacy version ' \
        'or to \'EDGE_CHROMIUM\' for the new Chromium-based version.'
      )
      return EDGE_LEGACY
    end
    super
  end

  def enum_values
    [
      CHROME,
      CHROME_ONE_VERSION_BACK,
      CHROME_TWO_VERSIONS_BACK,
      FIREFOX,
      FIREFOX_ONE_VERSION_BACK,
      FIREFOX_TWO_VERSIONS_BACK,
      SAFARI,
      SAFARI_ONE_VERSION_BACK,
      SAFARI_TWO_VERSIONS_BACK,
      IE_11,
      EDGE_LEGACY,
      IE_10,
      EDGE_CHROMIUM,
      EDGE_CHROMIUM_ONE_VERSION_BACK,
      IOS_SAFARI
    ]
  end
end
