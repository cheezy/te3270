require 'spec_helper'

describe TE3270::Emulators::X3270 do

  let(:x3270) { TE3270::Emulators::X3270.new }

  before(:each) do
    @x3270_io = double('x3270_io')
    Open3.stub(:popen2e).and_return [@x3270_io,@x3270_io,nil]
    x3270.instance_variable_set(:@executable_command, "the_command")
    x3270.instance_variable_set(:@host, "the_host")
    @x3270_io.stub(:print)
    @x3270_io.stub(:flush)
    @x3270_io.stub(:gets).and_return('goo','ok')
    end

  describe "global behaviors" do
    it 'should open pipe to x3270' do
      Open3.should_receive(:popen2e).and_return(x3270_system)
      x3270.connect
    end
   
    it 'should take the timeout value from a block' do
      x3270.should_receive(:executable_command=).with('path to the x3270 executable')
      x3270.connect do |platform|
        platform.executable_command = 'path to the x3270 executable'
      end
    end

    it 'should take the host to connect to from a block' do
      x3270.should_receive(:host=).with('name of host to connect to')
      x3270.connect do |platform|
        platform.host = 'name of host to connect to'
      end
    end

    it 'should take the max timeout value from a block' do
      x3270.should_receive(:max_wait_time=).with(42)
      x3270.connect do |platform|
        platform.max_wait_time = 42
      end
    end

    it 'should display an error when the path to the executable is not set' do
      x3270.instance_variable_set(:@executable_command, nil)
      expect { x3270.connect }.to raise_error('The executable command must be set in a block when calling connect with the X3270 emulator.')
    end

    it 'should display an error when the host is not set' do
      x3270.instance_variable_set(:@host, nil)
      expect { x3270.connect }.to raise_error('The host must be set in a block when calling connect with the X3270 emulator.')
    end

    it 'should default to max_wait_time being 10 when not provided' do
      #x3270.should_receive(:max_wait_time=).with(10)
      x3270.connect
      x3270.instance_variable_get(:@max_wait_time).should eq(10)
    end

    it 'should display an error when cannot popen supplied x3270 program' do
      Open3.stub(:popen2e).and_raise('darn it, popen failed')
      expect { x3270.connect }.to raise_error( "Could not start x3270 'the_command': darn it, popen failed")
    end

    it 'should close input and output on pipe when disconnect called' do
      io = double('IO')
      Open3.stub(:popen2e).and_return([io,io,io])
      io.should_receive(:close).twice
      x3270.connect
      x3270.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      @x3270_io.should_receive(:print).with("ascii(0,1,7)\n")
      @x3270_io.stub(:gets).and_return('data: blah','goo','ok')
      #@x3270_io.stub(:gets).and_return('ok')
      x3270.connect
      x3270.get_string(1, 2, 7).should == 'blah'
    end

    it 'should put a value on the screen' do
      @x3270_io.should_receive(:print).with("MoveCursor(14,55)\n")
      @x3270_io.should_receive(:print).with('string "blah"'+"\n")
      x3270.connect
      x3270.put_string('blah', 15, 56)
    end

    it 'should put proper escape value on the screen' do
      @x3270_io.should_receive(:print).with("MoveCursor(14,55)\n")
      @x3270_io.should_receive(:print).with('string "ab\"cd"'+"\n")
      x3270.connect
      x3270.put_string('ab"cd', 15, 56)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      @x3270_io.should_receive(:print).with("Home\n")
      @x3270_io.should_receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Home)
    end

    it 'should know how to send program function keys ' do
      @x3270_io.should_receive(:print).with("Pf(13)\n")
      @x3270_io.should_receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Pf13)
    end

    it 'should know how to send program attention keys ' do
      @x3270_io.should_receive(:print).with("Pa(2)\n")
      @x3270_io.should_receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Pa2)
    end

    it 'should wait for a string to appear' do
      @x3270_io.should_receive(:print).with("ascii(2,9,6)\n")
      @x3270_io.should_receive(:gets).and_return('data: string','goo','ok')
      x3270.should_not_receive(:sleep)
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should timeout when wait for a string does not appear' do
      @x3270_io.should_receive(:print).with("ascii(2,9,6)\n").exactly(20).times
      @x3270_io.should_receive(:gets).and_return('data: stuff','goo','ok')
      x3270.should_receive(:sleep).exactly(20).times
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should find string after one sleep when waiting for a string to appear' do
      @x3270_io.should_receive(:print).with("ascii(2,9,6)\n").twice
      @x3270_io.should_receive(:gets).and_return('data: blah','goo','ok','data: string','goo','ok')
      x3270.stub(:sleep).with(0.5).once
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should wait for host' do
      @x3270_io.should_receive(:print).with("Wait(10,Output)\n")
      x3270.connect
      x3270.wait_for_host(10)
    end

    it 'should wait until the cursor is at a position' do
      @x3270_io.should_receive(:print).with("MoveCursor(5,8)\n")
      x3270.connect
      x3270.wait_until_cursor_at(6,9)
    end

    it 'should take screenshots' do
      File.should_receive(:exists?).and_return(false)
      File.should_not_receive(:delete)
      @x3270_io.should_receive(:print).with("printtext(file,image.txt)\n")
      x3270.connect
      x3270.screenshot("image.txt")
    end

    it 'should delete existing file when taking screenshots' do
      File.should_receive(:exists?).and_return(true)
      File.should_receive(:delete)
      @x3270_io.should_receive(:print).with("printtext(file,image.txt)\n")
      x3270.connect
      x3270.screenshot("image.txt")
    end

    it 'should get all text from screen' do
      @x3270_io.should_receive(:print).with("ascii(0,0,1920)\n")
      @x3270_io.should_receive(:gets).and_return('data: string','goo','ok')
      x3270.connect
      x3270.text.should == 'string'
    end
  end
end