require 'open3'

module TE3270
  module Emulators
    #
    # This class has the code necessary to communicate with the terminal emulator called EXTRA! X-treme.
    # You can use this emulator by providing the +:extra+ parameter to the constructor of your screen
    # object or by passing the same value to the +emulator_for+ method on the +TE3270+ module.
    #
    class X3270

      attr_writer :executable_command, :host, :max_wait_time, :trace

      #
      # Creates a method to connect to x3270. This method expects a block in which certain
      # platform specific values can be set.  Extra can take the following parameters.
      #
      # * executable_command - this value is required and should be the name of the ws3270 executable
      # * host - this is required and is the (DNS) name of the host to connect to
      # * max_wait_time - max time to wait in wait_for_string (defaults to 10 if not specified)
      #
      # @example Example x3270 object constructor with a block
      #   screen_object = MyScreenObject.new(:x3270)
      #   screen_object.connect do |emulator|
      #     emulator.executable_command = 'path_to_executable'
      #     emulator.host = 'host.example.com'
      #     emulator.max_wait_time = 5
      #   end
      #
      def connect
        @max_wait_time = 10
        @trace = false
        yield self if block_given?
        raise 'The executable command must be set in a block when calling connect with the X3270 emulator.' if @executable_command.nil?
        raise 'The host must be set in a block when calling connect with the X3270 emulator.' if @host.nil?
        start_x3270_system
      end

      #
      # Disconnects the x3270 System connection
      #
      def disconnect
          @x3270_input.close
          @x3270_output.close
      end

      #
      # Extracts text of specified length from a start point.
      #
      # @param [Fixnum] row the x coordinate of location on the screen.
      # @param [Fixnum] column the y coordinate of location on the screen.
      # @param [Fixnum] length the length of string to extract
      # @return [String]
      # 
      def get_string row, column, length
        x_send "ascii(#{row-1},#{column-1},#{length})"
        result_string = ""
        while line = x_read do
          break if line == 'ok'
          result_string = result_string + line[6..-1] if line[0..5] == 'data: '
        end
        result_string
      end

      #
      # Puts string at the coordinates specified.
      #
      # @param [String] str the string to set
      # @param [Fixnum] row the x coordinate of the location on the screen.
      # @param [Fixnum] column the y coordinate of the location on the screen.
      #
      def put_string(str, row, column)
        x_send_no_rsp "MoveCursor(#{row-1},#{column-1})"
        x_send_no_rsp 'string "' + str.to_s.gsub('"', '\\"') + '"'
      end

      #
      # Sends keystrokes to the host, including function keys.
      #
      # @param [String] keys keystokes up to 255 in length
      #
      def send_keys(keys)
        key = keys[1..-2]
        if m=/^(Pf|Pa)(\d+)$/.match(key)
          key = "#{m[1]}(#{m[2]})"
        end
        x_send_no_rsp key
        x_send_no_rsp "wait(output)"
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
        x_send_no_rsp "Wait(#{seconds},Output)"
      end

      #
      # Waits until the cursor is at the specified location.
      #
      # @param [Fixnum] row the x coordinate of the location
      # @param [Fixnum] column the y coordinate of the location
      #
      def wait_until_cursor_at(row, column)
        x_send_no_rsp "MoveCursor(#{row-1},#{column-1})"
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
        x_send_no_rsp "printtext(file,#{filename})"
      end

      #
      # Returns the text of the active screen
      #
      # @return [String]
      #
      def text
        get_string(1,1,24*80)
      end

      private

      attr_reader :x3270_input, :x3270_output

      def x_read
        line = @x3270_output.gets.chomp
        puts "x_read: '#{line}'" if @trace
        line
      end

      def x_send cmd
        puts "x_send: #{cmd}" if @trace
        @x3270_input.print "#{cmd}\n"
        @x3270_input.flush
      end

      def x_send_no_rsp cmd
        x_send cmd
        while line = x_read do
          break if line == 'ok'
        end
      end

      def start_x3270_system
        begin
          args = [
              "-model", "2",
              ""
          ]
          cmd = "#{@executable_command} #{args.join " "} #{@host}"
          @x3270_input, @x3270_output, @x3270_thr = Open3.popen2e(cmd)
        rescue Exception => e
          raise "Could not start x3270 '#{@executable_command}': #{e}"
        end
      end
    end
  end
end
