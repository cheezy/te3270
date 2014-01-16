require 'te3270/version'
require 'te3270/accessors'
require 'te3270/screen_factory'
require 'te3270/function_keys'
require 'te3270/emulators/extra'

module TE3270
  extend FunctionKeys

  attr_reader :platform

  def self.included(cls)
    cls.extend TE3270::Accessors
  end

  def platform
    @platform ||= Extra.new
  end

  def connect
    platform.connect
  end

  def disconnect
    platform.disconnect
  end
end
