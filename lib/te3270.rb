require 'te3270/version'
require 'te3270/accessors'
require 'te3270/screen_factory'
require 'te3270/screen_populator'
require 'te3270/function_keys'
require 'te3270/emulator_factory'

#
# This gem can be used to drive a 3270 terminal emulator.  You have to have a supported emulator installed on the
# machines on which you use the gem.  Currently the supported emulators are EXTRA! X-treme by Attachmate,
# Quick3270 by DN-Computing, Virtel Web Access and X3270.  These are commercial products, with the exception of X3270,
# and you will need to purchase one of them in order to
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
  include ScreenPopulator
  extend FunctionKeys

  def self.included(cls)
    cls.extend TE3270::Accessors
  end

  #
  # Starts the terminal emulator and makes the connection.  This method requires a block
  # that has emulator specific information that is necessary to complete the connection.
  # To know what information you should provide in the block please see the classes in
  # the TE3270::Emulators package.
  #
  #@param platform =[:extra,:quick3270, :virtel] use :extra for Extra emulator, :quick3270 for quick emulator, :virtel
  #for Virtel Web access, and :x3270 for X3270
  #
  def self.emulator_for(platform, &block)
    platform_class = TE3270::EmulatorFactory.emulator_for(platform)
    @platform = platform_class.new
    @platform.connect &block
    @platform
  end

  #
  # Disconnects and closes the emulator
  #
  def self.disconnect(emulator)
    emulator.disconnect
  end

  def initialize(platform)
    @platform = platform
    initialize_screen if respond_to? :initialize_screen
  end

  #
  # Open a new screen and connect to the host.  Platform specific values are set by
  # passing a block to this method.  To see the valid platform specific values please
  # read the documentation for your emulator class in the TE3270::Emulators module.
  #
  def connect
    platform.connect
  end

  #
  # Disconnect from platform (extra or quick)
  #
  def disconnect
    platform.disconnect
  end

  #
  # Send keys on the emulator
  #
  def send_keys(keys)
    platform.send_keys(keys)
  end

  #
  # Retrieves the text from the current screen
  #
  def text
    platform.text
  end

  #
  # Takes screenshot and saves to the filename specified.  If you have visibility set to false
  # then this method will first of all make the screen visible, take the screenshot, and then
  # make set visibility to false again.
  #
  # @param [String] filename of the file to be saved.
  #
  def screenshot(filename)
    platform.screenshot(filename)
  end

  #
  # Waits for the string to appear at the specified location
  #
  # @param [String] String to wait for
  # @param [FixedNum] row number
  # @param [FixedNum] column number
  #
  def wait_for_string(str, row, column)
    platform.wait_for_string(str, row, column)
  end

  #
  # Waits for the host for specified # of seconds. Default is 5 seconds
  #
  # @param [FixedNum] seconds to wait for
  #
  def wait_for_host(seconds=5)
    platform.wait_for_host(seconds)
  end

  #
  # Waits for the cursor to appear at the specified location
  #
  # @param [FixedNum] row number
  # @param [FixedNum] column number
  #
  def wait_until_cursor_at(row, column)
    platform.wait_until_cursor_at(row, column)
  end

  private

  def platform
    @platform ||= Extra.new
  end

end
