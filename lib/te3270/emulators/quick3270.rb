require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Quick3270

      attr_reader :system, :session, :screen
      attr_writer :visible

      def connect
        start_quick_system
        yield self if block_given?
        establish_session
      end

      def disconnect
        session.Disconnect
        system.Application.Quit
      end

      private

      def visible
        @visible.nil? ? true : @visible
      end

      def start_quick_system
        begin
          @system = WIN32OLE.connect('Quick3270.Application')
        rescue
          @system = WIN32OLE.new('Quick3270.Application')
        end
      end

      def establish_session
        @system.Visible = visible
        @session = system.ActiveSession
        @screen = session.Screen
        session.Connect
      end

    end
  end
end
