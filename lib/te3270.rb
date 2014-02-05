require 'te3270/version'
require 'te3270/accessors'
require 'te3270/screen_factory'
require 'te3270/function_keys'
require 'te3270/emulator_factory'
require 'te3270/emulators/extra'
require 'te3270/emulators/quick3270'

#
# This gem can be used to drive a 3270 terminal emulator.  You have to have a supported emulator installed on the
# machines on which you use the gem.  Currently the only supported emulators are EXTRA! X-treme by Attachmate and
# Quick3270 by DN-Computing.  These are commercial products and you will need to purchase one of them in order to
# use this gem.  We do plan to support other emulators as time permits.
#
# This gem has been designed to work very similar to the page-object gem.  You will use it to create screen objects
# for each screen in your application.  Here is an example of one and how it can be used:
#
# @example Example mainframe page
#   class MainframeScreen
#     include TE3270
#
#     text_field(:userid, 10, 30, 20, true)
#     text_field(:password, 12, 30, 20, true)
#   end
#
#    ...
#
#   emulator = TN3270.emulator_for :extra do |emulator|
#     emulator.session_file = 'path_to_session_file'
#   end
#   my_screen = MainframeScreen.new(emulator)
#   my_screen.userid = 'the_id'
#   my_screen.password = 'the_password'
#
# Another option is to mixin the +TE3270::ScreenFactory+ module on use the factory methods to create the screen
# objects.  If you are using Cucumber you can do this by calling the +World+ method in your env.rb file.  Then
# you can use the factory and navigation methods in your step definitions.
#
# @example Registering the ScreenFactory with Cucumber World
#   World(TE3270::ScreenFactory)
#
#   Before do
#     @emulator = TE3270.emulator_for :quick3270 do |emulator|
#       emulator.session_file = 'path_to_session_file'
#     end
#   end
#
#
# @example Using the factory method in a step definition
#   on(MainframeScreen).do_something
#
#
# @see  #TE3270::ScreenFactory for more details on using the factory and navigation methods
#
module TE3270
  extend FunctionKeys

  def self.included(cls)
    cls.extend TE3270::Accessors
  end

  def self.emulator_for(platform, &block)
    platform_class = TE3270::EmulatorFactory.emulator_for(platform)
    @platform = platform_class.new
    @platform.connect &block
    @platform
  end

  def self.disconnect(emulator)
    emulator.disconnect
  end

  def initialize(platform)
    @platform = platform
    initialize_screen if respond_to? :initialize_screen
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

  def wait_for_string(str, row, column)
    platform.wait_for_string(str, row, column)
  end

  def wait_for_host(seconds=5)
    platform.wait_for_host(seconds)
  end

  def wait_until_cursor_at(row, column)
    platform.wait_until_cursor_at(row, column)
  end
end
