require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Extra

      attr_reader :system, :sessions, :session, :screen, :area
      attr_writer :session_file, :visible, :window_state

      WINDOW_STATES = {
          minimized: 0,
          normal: 1,
          maximized: 2
      }

      def connect
        start_extra_system

        yield self if block_given?

        close_all_sessions
        open_session
        @screen = session.Screen
        @area = screen.SelectAll
      end

      def disconnect
        session.Close if session
        system.Quit
      end

      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      def put_string(str, row, column)
        screen.PutString(str, row, column)
        screen.SendKeys(TE3270.Enter)
      end

      def send_keys(keys)
        screen.SendKeys(keys)
      end

      def wait_for_string(str)
        screen.WaitForString(str)
      end

      def wait_for_host(seconds)
        screen.WaitHostQuiet(seconds*1000)
      end

      def screenshot(filename)
        hwnd = session.WindowHandle
        Win32::Screenshot::Take.of(:window, hwnd: hwnd).write(filename)
      end

      def text
        area.Value
      end

      private

      def window_state
        @window_state.nil? ? 1 : WINDOW_STATES[@window_state]
      end

      def visible
        @visible.nil? ? true : @visible
      end

      def open_session
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
          @system = WIN32OLE.connect('EXTRA.System')
        rescue
          @system = WIN32OLE.new('EXTRA.System')
        end
      end
    end
  end
end