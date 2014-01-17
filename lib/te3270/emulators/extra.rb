require 'win32ole'

module TE3270
  module Emulators
    class Extra

      attr_reader :system, :sessions, :session, :screen
      attr_writer :session_file, :visible

      def connect
        begin
          @system = WIN32OLE.connect('EXTRA.System')
        rescue
          @system = WIN32OLE.new('EXTRA.System')
        end

        yield self if block_given?

        @sessions = system.Sessions
        @sessions.CloseAll if sessions.Count > 0

        open_session
        @screen = session.Screen
      end

      def disconnect
        session.Close if session
      end

      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      def put_string(str, row, column)
        screen.PutString(str, row, column)
      end

      def send_keys(keys)
        screen.SendKeys(keys)
      end

      def wait_for_string(str)
        screen.WaitForString(str)
      end

      def wait_for_host(seconds)
        screen.WaitHostQuiet(seconds)
      end

      private

      def open_session
        @session = sessions.Open @session_file
        @session.WindowState = 1
        @session.Visible = (@visible ? @visible : true)
      end
    end
  end
end