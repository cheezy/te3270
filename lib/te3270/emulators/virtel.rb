module TE3270
  module Emulators
    #
    # This class has the code necessary to communicate with the terminal emulator called Virtel.
    # It is a browser based terminal emulator. Watir webdriver (chrome only) is used to drive a browser with VWS (Virtel Web Access)
    # You can use this emulator by providing the +:virtel+ parameter to the constructor of your screen
    # object or by passing the same value to the +emulator_for+ method on the +TE3270+ module.
    #
    class Virtel

      attr_writer :url, :max_wait_time
      WAIT_SLEEP_INTERVAL = 0.2 # How long should we sleep during the wait loop.

      def initialize
        require 'watir-webdriver'
      end

      #
      # Creates a method to connect to Virtel System. This method expects a block in which certain
      # platform specific values can be set.  Extra can take the following parameters.
      #
      # * url - this value is required and should be the url of the session.
      # * max_wait_time - max time to wait in wait_for_string (defaults to 10 if not specified)
      #
      # @example Example calling screen object constructor with a block
      #   screen_object = MyScreenObject.new(:virtel)
      #   screen_object.connect do |emulator|
      #     emulator.url = 'http://mainframe:41001/w2h/WEB2AJAX.htm+Sessmgr'
      #   end
      #
      def connect
        @max_wait_time = 10
        yield self if block_given?
        start_virtel_browser

        raise 'The url must be set in a block when calling connect with the Virtel emulator.' if @url.nil?
      end

      #
      # Disconnects the Virtel System connection
      #
      def disconnect
        @browser.close
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
        @browser.execute_script <<-JS
          return VIR3270.getBoxedText("#{row}", "#{column}", 1, "#{length}");
        JS
      end

      #
      # Puts string at the coordinates specified.
      #
      # @param [String] str the string to set
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def put_string(str, row, column)
        move_to(row, column)
        @browser.execute_script <<-JS
          VIR3270.pasteByTyping("#{str}");
        JS
        quiet_period
      end

      #
      # Moves string at the coordinates specified.
      #
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def move_to(row, column)
        @browser.execute_script <<-JS
          var row = parseInt("#{row}", 10);
          var col = parseInt("#{column}", 10);

          VIR3270.moveCursorToPos(VIR3270.posFromRowCol(row, col));
        JS
      end

      #
      # Sends keystrokes to the host, including function keys.
      #
      # @param [String] keys keystokes up to 255 in length
      #
      def send_keys(keys)
        char_input_keys = ['ErEof','Reset']
        if char_input_keys.include?(keys)
          @browser.execute_script <<-JS
            VIR3270.charInput("#{keys}");
          JS
        else
          @browser.execute_script <<-JS
            sendWithSpecialKey("#{keys}");
          JS
        end
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
        total_time = 0.0
        sleep_time = 0.5
        while get_string(row, column, str.length) != str do
          sleep sleep_time
          total_time = total_time + sleep_time
          break if total_time >= @max_wait_time
        end
      end

      #
      # Waits for the host to not send data for a specified number of seconds
      #
      # @param [Fixnum] seconds the maximum number of seconds to wait
      #
      def wait_for_host(seconds)
        milliseconds = seconds * 1000
        sleep(WAIT_SLEEP_INTERVAL)
        @browser.execute_script <<-JS
          function virtelWaiting(){
              if (VIR3270.waitlocked === false)
                {return true;}
              else
                {return false;}
          };

          function waitOnVirtel(){
            for (var count = 1; ; count++) {
                if (setInterval(virtelWaiting(), 200))
                    {
                      return true;
                    }
                }
            }
          setTimeout(waitOnVirtel(), "#{milliseconds}");
        JS
      end

      #
      # Waits until the cursor is at the specified location.
      #
      # @param [Fixnum] row the x coordinate of the location
      # @param [Fixnum] column the y coordinate of the location
      #
      def wait_until_cursor_at(row, column)
        wait_until do
          @browser.execute_script <<-JS
            return (VIR3270.rowFromPos(VIR3270.cursorPosn) === parseInt("#{row}", 10)) && (VIR3270.colFromPos(VIR3270.cursorPosn) === parseInt("#{column}", 10))
          JS
        end
      end

      #
      # Returns the text of the active screen
      #
      # @return [String]
      #
      def text
        @browser.execute_script <<-JS
          VIR3270.collectText(1,1,VIR3270.rows,VIR3270.cols)
        JS
      end

      #
      # Creates a method to take screenshot of the active screen.
      #
      # @param [String] filename the path and name of the screenshot file to be saved
      #
      def screenshot(filename)
        File.delete(filename) if File.exists?(filename)

        @browser.screenshot.save(filename)
      end

      def start_virtel_browser
        begin
          @browser = Watir::Browser.new :chrome
          @browser.goto(@url)
        rescue Exception => e
          $stderr.puts e
        end
      end

      private

      def quiet_period
        wait_for_host(max_wait_time)
      end

      def max_wait_time
        @max_wait_time ||= 10
      end
    end
  end
end
