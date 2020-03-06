module TE3270
  module Emulators
    class BlueZoneError < StandardError; end
    class InvalidVisibleStateError < BlueZoneError; end
    class InvalidWindowStateError < BlueZoneError; end
    class SessionFileMissingError < BlueZoneError; end
    class Win32OleRuntimeError < BlueZoneError; end

    #
    # This class has the code necessary to communicate with the terminal emulator called Rocket BlueZone.
    # You can use this emulator by providing the +:bluezone+ parameter to the constructor of your screen
    # object or by passing the same value to the +emulator_for+ method on the +TE3270+ module.
    #
    class BlueZone
      attr_writer :connect_retry_timeout,
                  :max_column_length,
                  :max_wait_time,
                  :session_id,
                  :session_file,
                  :timeout

      #
      # Initialize the emulator with defaults. This also loads libraries used
      # to take screenshots on supported platforms.
      #
      def initialize
        @connect_retry_timeout = 30
        @max_column_length = 80
        @max_wait_time = 1000
        @session_file = nil
        @session_id = 1
        @timeout = 10
        @visible = true
        @window_state = :normal

        if jruby?
          require 'jruby-win32ole'
          require 'java'
          include_class 'java.awt.Dimension'
          include_class 'java.awt.Rectangle'
          include_class 'java.awt.Robot'
          include_class 'java.awt.Toolkit'
          include_class 'java.awt.event.InputEvent'
          include_class 'java.awt.image.BufferedImage'
          include_class 'javax.imageio.ImageIO'
        else
          require 'win32ole'
          require 'win32/screenshot'
        end
      end

      #
      # Creates a method to connect to BlueZone. This method expects a block in which certain
      # platform specific values can be set. BlueZone can take the following parameters.
      #
      # * connect_retry_timeout - number of seconds to retry connecting to a session. Defaults to +30+.
      # * max_column_length - number of columns in a terminal row. Defaults to +80+.
      # * max_wait_time - number of milliseconds to wait before resuming script execution after sending keys from host. Defaults to +1000+.
      # * session_file - this value is required and should be the filename of the session.
      # * session_id - numeric identifier for type of session to connect to. From BlueZone's docs: +1 for S1: 2 for S2; 3 for S3; etc.+ Defaults to +1+.
      # * timeout - numeric number of seconds till system calls timeout. Defaults to +10+.
      # * visible - determines if the emulator is visible or not. If not set it will default to +true+.
      # * window_state - determines the state of the session window.  Valid values are +:minimized+,
      #   +:normal+, and +:maximized+.  If not set it will default to +:normal+.
      #
      # @example Example calling screen object constructor with a block
      #   screen_object = MyScreenObject.new(:bluezone)
      #   screen_object.connect do |emulator|
      #     emulator.session_file = 'path_to_session_file'
      #     emulator.visible = true
      #     emulator.window_state = :maximized
      #   end
      #
      def connect
        start_bluezone_system
        yield self if block_given?
        raise SessionFileMissingError if @session_file.nil?

        result = system.OpenSession(SESSION_TYPE[:Mainframe], @session_id, @session_file, @timeout, 1)
        raise BlueZoneError, "Error opening session: #{result}; #{@session_file}" if result != 0

        result = system.Connect('!', @connect_retry_timeout)
        raise BlueZoneError, "Error connecting to session: #{result}" if result != 0
      end

      #
      # Disconnects the BlueZone connection
      #
      def disconnect
        system.CloseSession(SESSION_TYPE[:Mainframe], @session_id)
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
        system.PSGetText(length, ((row - 1) * @max_column_length) + column)
      end

      #
      # Puts string at the coordinates specified.
      #
      # @param [String] str the string to set
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def put_string(str, row, column)
        system.WriteScreen(str, row, column)
        system.WaitReady(@timeout, @max_wait_time)
      end

      #
      # Creates a method to take screenshot of the active screen. If you have set the +:visible+
      # property to false it will be made visible prior to taking the screenshot and then changed
      # to invisible after.
      #
      # @param [String] filename the path and name of the screenshot file to be saved
      #
      def screenshot(filename)
        File.delete(filename) if File.exists?(filename)
        original_visibility = @visible
        self.visible = true

        if jruby?
          toolkit = Toolkit::getDefaultToolkit()
          screen_size = toolkit.getScreenSize()
          rect = Rectangle.new(screen_size)
          robot = Robot.new
          image = robot.createScreenCapture(rect)
          f = java::io::File.new(filename)
          ImageIO::write(image, "png", f)
        else
          hwnd = system.WindowHandle
          Win32::Screenshot::Take.of(:window, hwnd: hwnd).write(filename)
        end

        self.visible = false unless original_visibility
      end

      #
      # Sends keystrokes to the host, including function keys.
      #
      # @param [String] keys keystokes up to 255 in length
      #
      def send_keys(keys)
        system.SendKey(keys)
        system.WaitReady(@timeout, @max_wait_time)
      end

      #
      # Returns the text of the active screen
      #
      # @return [String]
      #
      def text
        system.PSText
      end

      #
      # Sets the currently connected windows visibility.
      #
      # @param [Bool] value
      #
      def visible=(value)
        raise InvalidVisibleStateError, value unless [false, true].include?(value)

        @visible = value
        window = system.Window
        window.Visible = value
      end

      #
      # Waits for the host to not send data for a specified number of seconds
      #
      # @param [Fixnum] seconds the maximum number of seconds to wait
      #
      def wait_for_host(seconds)
        system.Wait(seconds)
      end

      #
      # Wait for the string to appear at the specified location
      #
      # @param [String] str the string to wait for
      # @param [Fixnum] row the x coordinate of location
      # @param [Fixnum] column the y coordinate of location
      #
      def wait_for_string(str, row, column)
        system.WaitForText(str, row, column, @timeout)
      end

      #
      # Waits until the cursor is at the specified location.
      #
      # @param [Fixnum] row the x coordinate of the location
      # @param [Fixnum] column the y coordinate of the location
      #
      def wait_until_cursor_at(row, column)
        system.WaitCursor(@timeout, row, column, 3)
      end

      #
      # Sets the currently connected windows state.
      #
      # @param [Symbol] state
      #
      def window_state=(state)
        raise InvalidWindowStateError, state unless WINDOW_STATE.keys.include?(state)

        @window_state = state
        system.WindowState = WINDOW_STATE[state]
      end

      private

      SESSION_TYPE = {
        Mainframe: 0,
        iSeries: 1,
        VT: 2,
        UTS: 3,
        T27: 4,
        '6530': 6
      }.freeze

      WINDOW_STATE = {
        maximized: 2,
        minimized: 1,
        normal: 0
      }.freeze

      attr_reader :system

      def jruby?
        RUBY_PLATFORM == 'java'
      end

      def start_bluezone_system
        begin
          @system = WIN32OLE.new('BZWhll.WhllObj')

          # Default window state.
          # Once session is "connected" these will be applied unless overwritten.
          self.window_state = @window_state
          self.visible = @visible
        rescue Win32OleRuntimeError => exception
          $stderr.puts exception
          raise MissingOleRuntimeError, 'Unable to find BZWhll.WhllObj OLE runtime. Did you install the same BlueZone Desktop architecture as your Ruby runtime? ex: x86 vs 64 bit'
        end
      end
    end
  end
end
