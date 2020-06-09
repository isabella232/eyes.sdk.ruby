module IosScreenshotOrientation
  extend self
  PORTRAIT ='portrait'
  LANDSCAPE_LEFT = 'landscapeLeft'
  LANDSCAPE_RIGHT = 'landscapeRight'

  def enum_values
    [
      PORTRAIT,
      LANDSCAPE_LEFT,
      LANDSCAPE_RIGHT
    ]
  end
end