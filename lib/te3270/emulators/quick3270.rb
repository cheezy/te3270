require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Quick3270

      attr_reader :system, :session, :screen
      attr_writer :session_file, :visible, :max_wait_time

      def connect
        start_quick_system
        yield self if block_given?
        raise "The session file must be set in a block when calling connect with the Quick3270 emulator." if @session_file.nil?
        establish_session
      end

      def disconnect
        session.Disconnect
        system.Application.Quit
      end

      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      def put_string(str, row, column)
        screen.MoveTo(row, column)
        screen.PutString(str)
        quiet_period
      end

      def send_keys(keys)
        screen.SendKeys(keys)
        quiet_period
      end

      def wait_for_string(str, row, column)
        screen.WaitForString(str, row, column)
      end

      def wait_for_host(seconds)
        screen.WaitHostQuiet(seconds * 1000)
      end

      def wait_until_cursor_at(row, column)
        screen.WaitForCursor(row, column)
      end

      def screenshot(filename)
        title = system.WindowTitle
        Win32::Screenshot::Take.of(:window, title: title).write(filename)
      end

      def text
        rows = screen.Rows
        columns = screen.Cols
        result = ''
        rows.times { |row| result += "#{screen.GetString(row+1, 1, columns)}\\n" }
        result
      end

      private

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
