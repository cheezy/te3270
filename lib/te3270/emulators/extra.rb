module TE3270
  module Emulators
    #
    # This class has the code necessary to communicate with the terminal emulator called EXTRA! X-treme.
    # You can use this emulator by providing the +:extra+ parameter to the constructor of your screen
    # object or by passing the same value to the +emulator_for+ method on the +TE3270+ module.
    #
    class Extra

      attr_writer :session_file, :visible, :window_state, :max_wait_time


      def initialize
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
      # Creates a method to connect to Extra System. This method expects a block in which certain
      # platform specific values can be set.  Extra can take the following parameters.
      #
      # * session_file - this value is required and should be the filename of the session.
      # * visible - determines if the emulator is visible or not. If not set it will default to +true+.
      # * window_state - determines the state of the session window.  Valid values are +:minimized+,
      #   +:normal+, and +:maximized+.  If not set it will default to +:normal+.
      #
      # @example Example calling screen object constructor with a block
      #   screen_object = MyScreenObject.new(:extra)
      #   screen_object.connect do |emulator|
      #     emulator.session_file = 'path_to_session_file'
      #     emulator.visible = true
      #     emulator.window_state = :maximized
      #   end
      #
      def connect
        start_extra_system

        yield self if block_given?
        raise 'The session file must be set in a block when calling connect with the Extra emulator.' if @session_file.nil?
        open_session
        @screen = session.Screen
        @area = screen.SelectAll
      end

      #
      # Disconnects the Extra System connection
      #
      def disconnect
        session.Close
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


      #___________________________________________

      #
      # Send File Method 
      #
      # @param [String]     filePath Full file path of Local file
      # @param [String]     fileHost Name of the Mainframe file
      # @param [Bool]       showHostDialog Show File transfer dialog or not
      #
      def send_Host_File(filePath, fileHost, showHostDialog)

          begin
              if showHostDialog != true
                showHostDialog = false
              end
          rescue
                showHostDialog = false
          end
          
          session.FileTransferScheme = "Text Default"
          session.FileTransferHostOS = 1 # For TSO transfer Default
          session.SendFile(filePath, fileHost, showHostDialog)
          quiet_period

      end


      #
      # Receive File Method
      #
      # @param [String]     filePath Full file path of Local file
      # @param [String]     fileHost Name of the Mainframe file
      # @param [Bool]       showHostDialog Show File transfer dialog or not
      #
      def recv_Host_File(filePath, fileHost, showHostDialog)

          begin
              if showHostDialog != true
                showHostDialog = false
              end
          rescue
                showHostDialog = false
          end

          session.FileTransferScheme = "Text Default"
          session.FileTransferHostOS = 1 # For TSO transfer Default
          session.ReceiveFile(filePath, fileHost, showHostDialog)
          quiet_period

      end

      #___________________________________________
      #
      # Puts string at the coordinates specified.
      #
      # @param [String] str the string to set
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def put_string(str, row, column)
        screen.PutString(str, row, column)
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
        wait_for do
          screen.WaitForString(str, row, column)
        end
      end

      #
      # Waits for the host to not send data for a specified number of seconds
      #
      # @param [Fixnum] seconds the maximum number of seconds to wait
      #
      def wait_for_host(seconds)
        wait_for(seconds) do
          screen.WaitHostQuiet
        end
      end

      #
      # Waits until the cursor is at the specified location.
      #
      # @param [Fixnum] row the x coordinate of the location
      # @param [Fixnum] column the y coordinate of the location
      #
      def wait_until_cursor_at(row, column)
        wait_for do
          screen.WaitForCursor(row, column)
        end
      end

      #
      # Set Dialog True or False
      # @param [Bool]     True or False - Show or Hide Dialog Default False
      #
      def  set_Show_Host_Dialog(showHostDialog_Received)
        begin
          if showHostDialog_Received != true
            return false
          end
          return true
        rescue
          return false
        end
      end

      # Send File Method: Support for Text TSO uploads only
      #
      # @param [String]     filePath Full file path of Local file
      # @param [String]     fileHost Name of the Mainframe file
      # @param [Bool]       showHostDialog Show File transfer dialog or not
      #
      def send_Host_File(filePath, fileHost, showHostDialog_Passed)
        create_Show_Dialog = set_Show_Host_Dialog(showHostDialog_Passed)
        session.FileTransferScheme = "Text Default"
        session.FileTransferHostOS = 1 # For TSO transfer Default
        session.SendFile(filePath, fileHost, create_Show_Dialog)
        quiet_period
      end

      #
      # Receive File Method: Support for Text TSO Downloads only
      #
      # @param [String]     filePath Full file path of Local file
      # @param [String]     fileHost Name of the Mainframe file
      # @param [Bool]       showHostDialog Show File transfer dialog or not
      #
      def recv_Host_File(filePath, fileHost, showHostDialog_Passed)
        create_Show_Dialog = set_Show_Host_Dialog(showHostDialog_Passed)
        session.FileTransferScheme = "Text Default"
        session.FileTransferHostOS = 1 # For TSO transfer Default
        session.ReceiveFile(filePath, fileHost, create_Show_Dialog)
        quiet_period
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
        session.Visible = true unless visible

        if jruby?
          toolkit = Toolkit::getDefaultToolkit()
          screen_size = toolkit.getScreenSize()
          rect = Rectangle.new(screen_size)
          robot = Robot.new
          image = robot.createScreenCapture(rect)
          f = java::io::File.new(filename)
          ImageIO::write(image, "png", f)
        else
          hwnd = session.WindowHandle
          Win32::Screenshot::Take.of(:window, hwnd: hwnd).write(filename)
        end

        session.Visible = false unless visible
      end

      #
      # Returns the text of the active screen
      #
      # @return [String]
      #
      def text
        area.Value
      end

      private

      attr_reader :system, :sessions, :session, :screen, :area

      WINDOW_STATES = {
          minimized: 0,
          normal: 1,
          maximized: 2
      }

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
        @sessions = system.Sessions
        hide_splash_screen
        @session = sessions.Open @session_file
        @session.WindowState = window_state
        @session.Visible = visible
      end

      def start_extra_system
        begin
          @system = WIN32OLE.new('EXTRA.System')
        rescue Exception => e
          $stderr.puts e
        end
      end

      def jruby?
        RUBY_PLATFORM == 'java'
      end
    end
  end
end
