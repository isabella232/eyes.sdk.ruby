# frozen_string_literal: true
module Orientations
  extend self
  PORTRAIT = 'portrait'
  LANDSCAPE = 'landscape'

  def enum_values
    [PORTRAIT, LANDSCAPE]
  end
end
