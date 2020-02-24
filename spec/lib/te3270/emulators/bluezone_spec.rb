require 'spec_helper'

describe TE3270::Emulators::BlueZone do

  unless Gem.win_platform?
    class WIN32OLE
    end
  end

  let(:bluezone) do
    allow_any_instance_of(TE3270::Emulators::BlueZone).to receive(:require) unless Gem.win_platform?
    TE3270::Emulators::BlueZone.new
  end

  before(:each) do
    allow(WIN32OLE).to receive(:new).and_return bluezone_system
    bluezone.instance_variable_set(:@session_file, 'the_file')
    allow(File).to receive(:exists).and_return false
  end


  describe "global behaviors" do
    it 'should start a new terminal' do
      expect(WIN32OLE).to receive(:new).and_return(bluezone_system)
      bluezone.connect
    end

    it 'should open a session' do
      expect(bluezone_system).to receive(:OpenSession).and_return(0)
      bluezone.connect
    end

    it 'should call a block allowing the session file to be set' do
      expect(bluezone_system).to receive(:OpenSession).with(0, 1, 'blah.edp', 10, 1).and_return(0)
      bluezone.connect do |platform|
        platform.session_file = 'blah.edp'
      end
    end

    it 'should call a block with custom session number to be set' do
      expect(bluezone_system).to receive(:OpenSession).with(0, 2, 'blah.edp', 10, 1).and_return(0)
      bluezone.connect do |platform|
        platform.session_id = 2
        platform.session_file = 'blah.edp'
      end
    end

    it 'should raise an error when the session file is not set' do
      bluezone.instance_variable_set(:@session_file, nil)
      expect { bluezone.connect }.to raise_error(TE3270::Emulators::SessionFileMissingError)
    end

    it 'should take the visible value from a block' do
      expect(bluezone_window).to receive(:Visible=).with(false)
      bluezone.connect do |platform|
        platform.visible = false
      end
    end

    it 'should default to visible when not specified' do
      expect(bluezone_window).to receive(:Visible=).with(true)
      bluezone.connect
    end

    it 'should take the window state value from the block' do
      expect(bluezone_system).to receive(:WindowState=).with(2)
      bluezone.connect do |platform|
        platform.window_state = :maximized
      end
    end

    it 'should default to window state normal when not specified' do
      expect(bluezone_system).to receive(:WindowState=).with(0)
      bluezone.connect
    end

    it 'should get the connection for the active session' do
      expect(bluezone_system).to receive(:Connect).with("!", 30).and_return(0)
      bluezone.connect
    end

    it 'should get the connection with custom connection retry timeout for the active session' do
      expect(bluezone_system).to receive(:Connect).with("!", 0).and_return(0)
      bluezone.connect_retry_timeout = 0
      bluezone.connect
    end

    it 'should disconnect from a session' do
      expect(bluezone_system).to receive(:CloseSession).with(0, 1)
      bluezone.connect
      bluezone.disconnect
    end

    it 'should disconnect from a custom session id' do
      expect(bluezone_system).to receive(:CloseSession).with(0, 2)
      bluezone.connect do |platform|
        platform.session_id = 2
      end
      bluezone.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      expect(bluezone_system).to receive(:PSGetText).with(10, 1532).and_return('blah')
      bluezone.connect
      expect(bluezone.get_string(20, 12, 10)).to eql 'blah'
    end

    it 'should get the value from the screen if columns were set to 100' do
      expect(bluezone_system).to receive(:PSGetText).with(10, 1912).and_return('blah')
      bluezone.connect do |platform|
        platform.max_column_length = 100
      end
      expect(bluezone.get_string(20, 12, 10)).to eql 'blah'
    end

    it 'should put the value on the screen' do
      expect(bluezone_system).to receive(:WriteScreen).with('blah', 1, 2)
      expect(bluezone_system).to receive(:WaitReady).with(10, 1000)
      bluezone.connect
      bluezone.put_string('blah', 1, 2)
    end

    it 'should put the value on the screen with reduced wait delay if overridden' do
      expect(bluezone_system).to receive(:WriteScreen).with('blah', 1, 2)
      expect(bluezone_system).to receive(:WaitReady).with(10, 100)
      bluezone.connect
      bluezone.max_wait_time = 100
      bluezone.put_string('blah', 1, 2)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      expect(bluezone_system).to receive(:SendKey).with('<Clear>')
      expect(bluezone_system).to receive(:WaitReady).with(10, 1000)
      bluezone.connect
      bluezone.send_keys(TE3270.Clear)
    end

    it 'should know how to send function keys with reduced wait delay if overridden' do
      expect(bluezone_system).to receive(:SendKey).with('<Clear>')
      expect(bluezone_system).to receive(:WaitReady).with(10, 100)
      bluezone.connect
      bluezone.max_wait_time = 100
      bluezone.send_keys(TE3270.Clear)
    end

    it 'should wait for a string to appear' do
      expect(bluezone_system).to receive(:WaitForText).with('The String', 3, 10, 10).and_return(0)
      bluezone.connect
      bluezone.wait_for_string('The String', 3, 10)
    end

    it 'should respect custom timeout for a string to appear' do
      expect(bluezone_system).to receive(:WaitForText).with('The String', 3, 10, 24).and_return(0)
      bluezone.connect
      bluezone.timeout = 24
      bluezone.wait_for_string('The String', 3, 10)
    end

    it 'should wait for the host to be quiet' do
      expect(bluezone_system).to receive(:Wait).with(4)
      bluezone.connect
      bluezone.wait_for_host(4)
    end

    it 'should wait until the cursor is at a position' do
      expect(bluezone_system).to receive(:WaitCursor).with(10, 5, 8, 3).and_return(0)
      bluezone.connect
      bluezone.wait_until_cursor_at(5, 8)
    end

    it 'should respect custom timeout while waiting until the cursor is at a position' do
      expect(bluezone_system).to receive(:WaitCursor).with(24, 5, 8, 3).and_return(0)
      bluezone.connect
      bluezone.timeout = 24
      bluezone.wait_until_cursor_at(5, 8)
    end

    it "should get the screen text" do
      expect(bluezone_system).to receive(:PSText).and_return('blah')
      bluezone.connect
      expect(bluezone.text).to eql 'blah'
    end

    if Gem.win_platform?
      it 'should take screenshots' do
        take = double('Take')
        expect(bluezone_system).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        bluezone.connect
        bluezone.screenshot('image.png')
      end

      it 'should make the window visible before taking a screenshot' do
        take = double('Take')
        expect(bluezone_system).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        expect(bluezone_window).to receive(:Visible=).twice.with(true)
        expect(bluezone_window).to receive(:Visible=).twice.with(false)
        bluezone.connect do |emulator|
          emulator.visible = false
        end
        bluezone.screenshot('image.png')
      end

      it 'should delete the file for the screenshot if it already exists' do
        expect(File).to receive(:exists?).and_return(true)
        expect(File).to receive(:delete)
        take = double('Take')
        expect(bluezone_system).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        bluezone.connect
        bluezone.screenshot('image.png')
      end
    end
  end
end
