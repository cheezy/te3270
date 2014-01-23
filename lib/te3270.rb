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

  def send_keys(keys)
    platform.send_keys(keys)
  end

  def screenshot(filename)
    platform.screenshot(filename)
  end

  def screentext
    platform.screentext
  end

  def wait_for_string(str)
    platform.wait_for_string(str)
  end

  def wait_for_host(seconds=5)
    platform.wait_for_host(seconds)
  end
end
