require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Extra

      attr_reader :system, :sessions, :session, :screen, :area
      attr_writer :session_file, :visible, :window_state, :max_wait_time

      WINDOW_STATES = {
          minimized: 0,
          normal: 1,
          maximized: 2
      }

      #
      # Creates a method to connect to Extra System. Closes existing sessions and initiates a new session
      # Gets the screen object from new session. Selects the screen area
      #
      def connect
        start_extra_system

        yield self if block_given?
        raise 'The session file must be set in a block when calling connect with the Extra emulator.' if @session_file.nil?
        close_all_sessions
        open_session
        @screen = session.Screen
        @area = screen.SelectAll
      end
      # Disconnects the Extra System connection
      def disconnect
        system.Quit
      end
      # Creates a method to extract text of specified length from a start point on the extra Screen object.
      # @param [int] the x coordinate of location on the screen.
      # @param [int] the y coordinate of location on the screen.
      # @param [int] the length of string to extract
      # @return [String]
      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      # Creates a method to put string at the coordinates specified on the extra Screen object.
      # Once the string is input, quiet period will ensure to not send data for a specified number of milliseconds
      # @param [int] the string to set
      # @param [int] the x coordinate of the location on the screen.
      # @param [int] the y coordinate of the location on the screen.
      def put_string(str, row, column)
        screen.PutString(str, row, column)
        quiet_period
      end

      # Creates a method to send keys to the screen. The keys are defined in function keys
      # @param [KEYS] the function keys defined by Extra System
      # Once the string is input, quiet period will ensure to not send data for a specified number of milliseconds
      def send_keys(keys)
        screen.SendKeys(keys)
        quiet_period
      end
      # Creates a method to wait for the string to appear at the location
      #@param [String] the string to wait for
      # @param [int] the x coordinate of location
      # @param [int] the y coordinate of location
      def wait_for_string(str, row, column)
        wait_for do
          screen.WaitForString(str, row, column)
        end
      end
      # Waits for the host to not send data for a specified number of seconds
      # @param [int] the number of seconds
      def wait_for_host(seconds)
        wait_for(seconds) do
          screen.WaitHostQuiet
        end
      end
      # Waits until the cursor is at the specified location.
      # @param [int] the x coordinate of the location
      # @param [int] the y coordinate of the location
      def wait_until_cursor_at(row, column)
        wait_for do
          screen.WaitForCursor(row, column)
        end
      end
      # Creates a method to take screenshot of the active screen
      # @param [String] the path and name of the screenshot file to be saved
      def screenshot(filename)
        File.delete(filename) if File.exists?(filename)
        session.Visible = true unless visible
        hwnd = session.WindowHandle
        Win32::Screenshot::Take.of(:window, hwnd: hwnd).write(filename)
        session.Visible = false unless visible
      end

      # Creates method to return the text of the active screen
      # @return [String]
      def text
        area.Value
      end

      private

      def wait_for(seconds = system.TimeoutValue / 1000)
        wait_collection = yield
        wait_collection.Wait(seconds * 1000)
      end

      def quiet_period
        wait_for_host(max_wait_time)
      end

      def max_wait_time
        @max_wait_time ||= 1
      end

      def window_state
        @window_state.nil? ? 1 : WINDOW_STATES[@window_state]
      end

      def visible
        @visible.nil? ? true : @visible
      end

      def hide_splash_screen
        version = system.Version
        sessions.VisibleOnStartup = true if version.to_i >= 9
      end

      def open_session
        hide_splash_screen
        @session = sessions.Open @session_file
        @session.WindowState = window_state
        @session.Visible = visible
      end

      def close_all_sessions
        @sessions = system.Sessions
        @sessions.CloseAll if sessions.Count > 0
      end

      def start_extra_system
        begin
          @system = WIN32OLE.new('EXTRA.System')
        rescue Exception => e
          $stderr.puts e
        end
      end
    end
  end
end