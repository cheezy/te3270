require 'spec_helper'


describe TE3270::Emulators::Extra do

  unless Gem.win_platform?
    class WIN32OLE
    end
  end

  let(:extra) do
    allow_any_instance_of(TE3270::Emulators::Extra).to receive(:require) unless Gem.win_platform?
    TE3270::Emulators::Extra.new
  end

  before(:each) do
    allow(WIN32OLE).to receive(:new).and_return extra_system
    extra.instance_variable_set(:@session_file, 'the_file')
    allow(File).to receive(:exists).and_return false
  end


  describe "global behaviors" do
    it 'should start a new terminal' do
      expect(WIN32OLE).to receive(:new).and_return(extra_system)
      extra.connect
    end

    it 'should open a session' do
      expect(extra_sessions).to receive(:Open).and_return(extra_session)
      extra.connect
    end

    it 'should not display the splash screen if version is higher than 9' do
      expect(extra_system).to receive(:Version).and_return("9.2")
      expect(extra_sessions).to receive(:VisibleOnStartup=).with(true)
      extra.connect
    end

    it 'should call a block allowing the session file to be set' do
      expect(extra_sessions).to receive(:Open).with('blah.edp').and_return(extra_session)
      extra.connect do |platform|
        platform.session_file = 'blah.edp'
      end
    end

    it 'should raise an error when the session file is not set' do
      extra.instance_variable_set(:@session_file, nil)
      expect { extra.connect }.to raise_error('The session file must be set in a block when calling connect with the Extra emulator.')
    end

    it 'should take the visible value from a block' do
      expect(extra_session).to receive(:Visible=).with(false)
      extra.connect do |platform|
        platform.visible = false
      end
    end

    it 'should default to visible when not specified' do
      expect(extra_session).to receive(:Visible=).with(true)
      extra.connect
    end

    it 'should take the window state value from the block' do
      expect(extra_session).to receive(:WindowState=).with(2)
      extra.connect do |platform|
        platform.window_state = :maximized
      end
    end

    it 'should default to window state normal when not specified' do
      expect(extra_session).to receive(:WindowState=).with(1)
      extra.connect
    end

    it 'should default to being visible' do
      expect(extra_session).to receive(:Visible=).with(true)
      extra.connect
    end

    it 'should get the screen for the active session' do
      expect(extra_session).to receive(:Screen).and_return(extra_screen)
      extra.connect
    end

    it 'should get the area from the screen' do
      expect(extra_screen).to receive(:SelectAll).and_return(extra_area)
      extra.connect
    end

    it 'should disconnect from a session' do
      expect(extra_session).to receive(:Close)
      extra.connect
      extra.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      expect(extra_screen).to receive(:GetString).with(1, 2, 10).and_return('blah')
      extra.connect
      expect(extra.get_string(1, 2, 10)).to eql 'blah'
    end

    it 'should put the value on the screen' do
      wait_collection = double('wait')
      expect(extra_screen).to receive(:PutString).with('blah', 1, 2)
      expect(extra_screen).to receive(:WaitHostQuiet).and_return(wait_collection)
      expect(wait_collection).to receive(:Wait).with(1000)
      extra.connect
      extra.put_string('blah', 1, 2)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      wait_collection = double('wait')
      expect(extra_screen).to receive(:SendKeys).with('<Clear>')
      expect(extra_screen).to receive(:WaitHostQuiet).and_return(wait_collection)
      expect(wait_collection).to receive(:Wait).with(1000)
      extra.connect
      extra.send_keys(TE3270.Clear)
    end

    it 'should wait for a string to appear' do
      wait_col = double('wait')
      expect(extra_screen).to receive(:WaitForString).with('The String', 3, 10).and_return(wait_col)
      expect(extra_system).to receive(:TimeoutValue).and_return(30000)
      expect(wait_col).to receive(:Wait).with(30000)
      extra.connect
      extra.wait_for_string('The String', 3, 10)
    end

    it 'should wait for the host to be quiet' do
      wait_col = double('wait')
      expect(extra_screen).to receive(:WaitHostQuiet).and_return(wait_col)
      expect(wait_col).to receive(:Wait).with(4000)
      extra.connect
      extra.wait_for_host(4)
    end

    it 'should wait until the cursor is at a position' do
      wait_col = double('wait')
      expect(extra_screen).to receive(:WaitForCursor).with(5, 8).and_return(wait_col)
      expect(extra_system).to receive(:TimeoutValue).and_return(30000)
      expect(wait_col).to receive(:Wait).with(30000)
      extra.connect
      extra.wait_until_cursor_at(5, 8)
    end

    if Gem.win_platform?

      it 'should take screenshots' do
        take = double('Take')
        expect(extra_session).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        extra.connect
        extra.screenshot('image.png')
      end

      it 'should make the window visible before taking a screenshot' do
        take = double('Take')
        expect(extra_session).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        expect(extra_session).to receive(:Visible=).once.with(true)
        expect(extra_session).to receive(:Visible=).twice.with(false)
        extra.connect do |emulator|
          emulator.visible = false
        end
        extra.screenshot('image.png')
      end

      it 'should delete the file for the screenshot if it already exists' do
        expect(File).to receive(:exists?).and_return(true)
        expect(File).to receive(:delete)
        take = double('Take')
        expect(extra_session).to receive(:WindowHandle).and_return(123)
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, hwnd: 123).and_return(take)
        expect(take).to receive(:write).with('image.png')
        extra.connect
        extra.screenshot('image.png')
      end
    end

    it "should get the screen text" do
      expect(extra_area).to receive(:Value).and_return('blah')
      extra.connect
      expect(extra.text).to eql 'blah'
    end

  end
end


