require 'spec_helper'

describe TE3270::Emulators::X3270 do

  let(:x3270) { TE3270::Emulators::X3270.new }

  before(:each) do
    @x3270_io = double('x3270_io')
    allow(Open3).to receive(:popen2e).and_return [@x3270_io,@x3270_io,nil]
    x3270.instance_variable_set(:@executable_command, "the_command")
    x3270.instance_variable_set(:@host, "the_host")
    allow(@x3270_io).to receive(:print)
    allow(@x3270_io).to receive(:flush)
    allow(@x3270_io).to receive(:gets).and_return('goo','ok')
    end

  describe "global behaviors" do
    it 'should open pipe to x3270' do
      expect(Open3).to receive(:popen2e).and_return(x3270_system)
      x3270.connect
    end
   
    it 'should take the timeout value from a block' do
      expect(x3270).to receive(:executable_command=).with('path to the x3270 executable')
      x3270.connect do |platform|
        platform.executable_command = 'path to the x3270 executable'
      end
    end

    it 'should take the host to connect to from a block' do
      expect(x3270).to receive(:host=).with('name of host to connect to')
      x3270.connect do |platform|
        platform.host = 'name of host to connect to'
      end
    end

    it 'should take the max timeout value from a block' do
      expect(x3270).to receive(:max_wait_time=).with(42)
      x3270.connect do |platform|
        platform.max_wait_time = 42
      end
    end

    it 'should take the connection port from a block' do
      expect(x3270).to receive(:port=).with(3270)
      x3270.connect do |platform|
        platform.port = 3270
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
      x3270.connect
      expect(x3270.instance_variable_get(:@max_wait_time)).to eql(10)
    end

    it 'should default to port being 23 when not provided' do
      x3270.connect
      expect(x3270.instance_variable_get(:@port)).to eql(23)
    end

    it 'should display an error when cannot popen supplied x3270 program' do
      allow(Open3).to receive(:popen2e).and_raise('darn it, popen failed')
      expect { x3270.connect }.to raise_error( "Could not start x3270 'the_command': darn it, popen failed")
    end

    it 'should close input and output on pipe when disconnect called' do
      io = double('IO')
      expect(Open3).to receive(:popen2e).and_return [io,io,io]
      allow(io).to receive(:close).twice
      x3270.connect
      x3270.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      expect(@x3270_io).to receive(:print).with("ascii(0,1,7)\n")
      expect(@x3270_io).to receive(:gets).and_return('data: blah','goo','ok')
      x3270.connect
      expect(x3270.get_string(1, 2, 7)).to eql 'blah'
    end

    it 'should put a value on the screen' do
      expect(@x3270_io).to receive(:print).with("MoveCursor(14,55)\n")
      expect(@x3270_io).to receive(:print).with('string "blah"'+"\n")
      x3270.connect
      x3270.put_string('blah', 15, 56)
    end

    it 'should put proper escape value on the screen' do
      expect(@x3270_io).to receive(:print).with("MoveCursor(14,55)\n")
      expect(@x3270_io).to receive(:print).with('string "ab\"cd"'+"\n")
      x3270.connect
      x3270.put_string('ab"cd', 15, 56)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      expect(@x3270_io).to receive(:print).with("Home\n")
      expect(@x3270_io).to receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Home)
    end

    it 'should know how to send program function keys ' do
      expect(@x3270_io).to receive(:print).with("Pf(13)\n")
      expect(@x3270_io).to receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Pf13)
    end

    it 'should know how to send program attention keys ' do
      expect(@x3270_io).to receive(:print).with("Pa(2)\n")
      expect(@x3270_io).to receive(:print).with("wait(output)\n")
      x3270.connect
      x3270.send_keys(TE3270.Pa2)
    end

    it 'should wait for a string to appear' do
      expect(@x3270_io).to receive(:print).with("ascii(2,9,6)\n")
      expect(@x3270_io).to receive(:gets).and_return('data: string','goo','ok')
      expect(x3270).not_to receive(:sleep)
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should timeout when wait for a string does not appear' do
      expect(@x3270_io).to receive(:print).with("ascii(2,9,6)\n").exactly(20).times
      expect(@x3270_io).to receive(:gets).and_return('data: stuff','goo','ok')
      expect(x3270).to receive(:sleep).exactly(20).times
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should find string after one sleep when waiting for a string to appear' do
      expect(@x3270_io).to receive(:print).with("ascii(2,9,6)\n").twice
      expect(@x3270_io).to receive(:gets).and_return('data: blah','goo','ok','data: string','goo','ok')
      expect(x3270).to receive(:sleep).with(0.5).once
      x3270.connect
      x3270.wait_for_string('string', 3, 10)
    end

    it 'should wait for host' do
      expect(@x3270_io).to receive(:print).with("Wait(10,Output)\n")
      x3270.connect
      x3270.wait_for_host(10)
    end

    it 'should wait until the cursor is at a position' do
      expect(@x3270_io).to receive(:print).with("MoveCursor(5,8)\n")
      x3270.connect
      x3270.wait_until_cursor_at(6,9)
    end

    it 'should take screenshots' do
      expect(File).to receive(:exists?).and_return(false)
      expect(File).not_to receive(:delete)
      expect(@x3270_io).to receive(:print).with("printtext(file,image.txt)\n")
      x3270.connect
      x3270.screenshot("image.txt")
    end

    it 'should delete existing file when taking screenshots' do
      expect(File).to receive(:exists?).and_return(true)
      expect(File).to receive(:delete)
      expect(@x3270_io).to receive(:print).with("printtext(file,image.txt)\n")
      x3270.connect
      x3270.screenshot("image.txt")
    end

    it 'should get all text from screen' do
      expect(@x3270_io).to receive(:print).with("ascii(0,0,1920)\n")
      expect(@x3270_io).to receive(:gets).and_return('data: string','goo','ok')
      x3270.connect
      expect(x3270.text).to eql 'string'
    end
  end
end