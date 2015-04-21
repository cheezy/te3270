if Gem.win_platform?
  require 'win32ole'
  require 'win32/screenshot'
end

module TE3270
  module Emulators

    #
    # This class has the code necessary to communicate with the terminal emulator called Quick3270.
    # You can use this emulator by providing the +:quick+ parameter to the constructor of your screen
    # object or by passing the same value to the +emulator_for+ method on the +TE3270+ module.
    #

    class Quick3270

      attr_writer :session_file, :visible, :max_wait_time

      #
      # Creates a method to connect to Quick System. This method expects a block in which certain
      # platform specific values can be set.  Quick can take the following parameters.
      #
      # * session_file - this value is required and should be the filename of the session.
      # * visible - determines if the emulator is visible or not. If not set it will default to +true+.
      #
      # @example Example calling screen object constructor with a block
      #   screen_object = MyScreenObject.new(:quick3270)
      #   screen_object.connect do |emulator|
      #     emulator.session_file = 'path_to_session_file'
      #     emulator.visible = true
      #   end
      #
      def connect
        start_quick_system
        yield self if block_given?
        raise "The session file must be set in a block when calling connect with the Quick3270 emulator." if @session_file.nil?
        establish_session
      end

      #
      # Disconnects the Quick System connection
      #
      def disconnect
        session.Disconnect
        system.Application.Quit
      end

      #
      # Extracts text of specified length from a start point.
      #
      # @param [Fixnum] row the x coordinate of location on the screen.
      # @param [Fixnum] column the y coordinate of location on the screen.
      # @param [Fixnum] length the length of string to extract
      # @return [String]
      #
      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      #
      # Puts string at the coordinates specified.
      #
      # @param [String] str the string to set
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def put_string(str, row, column)
        screen.MoveTo(row, column)
        screen.PutString(str)
        quiet_period
      end

      #
      # Sends keystrokes to the host, including function keys.
      #
      # @param [String] keys keystokes up to 255 in length
      #
      def send_keys(keys)
        screen.SendKeys(keys)
        quiet_period
      end

      #
      # Wait for the string to appear at the specified location
      #
      # @param [String] str the string to wait for
      # @param [Fixnum] row the x coordinate of location
      # @param [Fixnum] column the y coordinate of location
      #
      def wait_for_string(str, row, column)
        screen.WaitForString(str, row, column)
      end

      #
      # Waits for the host to not send data for a specified number of seconds
      #
      # @param [Fixnum] seconds the maximum number of seconds to wait
      #
      def wait_for_host(seconds)
        screen.WaitHostQuiet(seconds * 1000)
      end

      #
      # Waits until the cursor is at the specified location.
      #
      # @param [Fixnum] row the x coordinate of the location
      # @param [Fixnum] column the y coordinate of the location
      #
      def wait_until_cursor_at(row, column)
        screen.WaitForCursor(row, column)
      end

      #
      # Creates a method to take screenshot of the active screen.  If you have set the +:visible+
      # property to false it will be made visible prior to taking the screenshot and then changed
      # to invisible after.
      #
      # @param [String] filename the path and name of the screenshot file to be saved
      #
      def screenshot(filename)
        File.delete(filename) if File.exists?(filename)
        system.Visible = true unless visible
        title = system.WindowTitle
        Win32::Screenshot::Take.of(:window, title: title).write(filename)
        system.Visible = false unless visible
      end

      #
      # Returns the text of the active screen
      #
      # @return [String]
      #
      def text
        rows = screen.Rows
        columns = screen.Cols
        result = ''
        rows.times { |row| result += "#{screen.GetString(row+1, 1, columns)}\\n" }
        result
      end

      private

      attr_reader :system, :session, :screen

      def quiet_period
        screen.WaitHostQuiet(max_wait_time)
      end

      def max_wait_time
        @max_wait_time ||= 3000
      end

      def visible
        @visible.nil? ? true : @visible
      end

      def start_quick_system
        begin
          @system = WIN32OLE.new('Quick3270.Application')
        rescue Exception => e
          $stderr.puts e
        end
      end

      def establish_session
        system.Visible = visible
        @session = system.ActiveSession
        session.Open @session_file
        @screen = session.Screen
        session.Connect
        connected = session.Connected
        while not connected
          screen.WaitHostQuiet(1000)
          connected = session.Connected
        end
      end

    end
  end
end
