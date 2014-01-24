require 'te3270/version'
require 'te3270/accessors'
require 'te3270/screen_factory'
require 'te3270/function_keys'
require 'te3270/emulator_factory'
require 'te3270/emulators/extra'

# This gem can be used to drive a 3270 terminal emulator.  You have to have a supported emulator installed on the
# machines on which you use the gem.  Currently the only supported emulator is
# EXTRA! X-treme - http://www.attachmate.com/Products/Terminal+Emulation/Extra/xtreme/extra-x-treme.htm.
# This is a commercial product and you will need to purchase it in order to use this gem.
# We do plan to support other emulators as time permits.

module TE3270
  extend FunctionKeys

  def self.included(cls)
    cls.extend TE3270::Accessors
  end

  def self.emulator_for(platform)
    platform_class = TE3270::EmulatorFactory.emulator_for(platform)
    @platform = platform_class.new
    @platform.connect
    @platform
  end

  def self.disconnect(emulator)
    emulator.disconnect
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

  def text
    platform.text
  end

  def screenshot(filename)
    platform.screenshot(filename)
  end

  def wait_for_string(str)
    platform.wait_for_string(str)
  end

  def wait_for_host(seconds=5)
    platform.wait_for_host(seconds)
  end
end
