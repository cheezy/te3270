require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Quick3270

      attr_reader :system, :session

      def connect
        begin
          @system = WIN32OLE.connect('Quick3270.Application')
        rescue
          @system = WIN32OLE.new('Quick3270.Application')
        end

        @session = system.ActiveSession
      end
    end
  end
end
