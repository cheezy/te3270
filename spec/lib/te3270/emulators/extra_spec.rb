require 'spec_helper'

describe TE3270::Emulators::Extra do

  let(:extra) { TE3270::Emulators::Extra.new }

  before(:each) do
    WIN32OLE.stub(:new).and_return extra_system
    extra.instance_variable_set(:@session_file, 'the_file')
  end


  describe "global behaviors" do
    it 'should start a new terminal' do
      WIN32OLE.should_receive(:new).and_return(extra_system)
      extra.connect
    end

    it 'should open a session' do
      extra_sessions.should_receive(:Open).and_return(extra_session)
      extra.connect
    end

    it 'should not display the splash screen if version is higher than 9' do
      extra_system.should_receive(:Version).and_return("9.2")
      extra_sessions.should_receive(:VisibleOnStartup=).with(true)
      extra.connect
    end

    it 'should close all sessions if some are open' do
      extra_sessions.should_receive(:Count).and_return(1)
      extra_sessions.should_receive(:CloseAll)
      extra.connect
    end

    it 'should call a block allowing the session file to be set' do
      extra_sessions.should_receive(:Open).with('blah.edp').and_return(extra_session)
      extra.connect do |platform|
        platform.session_file = 'blah.edp'
      end
    end

    it 'should raise an error when the session file is not set' do
      extra.instance_variable_set(:@session_file, nil)
      expect { extra.connect }.to raise_error('The session file must be set in a block when calling connect with the Extra emulator.')
    end

    it 'should take the visible value from a block' do
      extra_session.should_receive(:Visible=).with(false)
      extra.connect do |platform|
        platform.visible = false
      end
    end

    it 'should default to visible when not specified' do
      extra_session.should_receive(:Visible=).with(true)
      extra.connect
    end

    it 'should take the window state value from the block' do
      extra_session.should_receive(:WindowState=).with(2)
      extra.connect do |platform|
        platform.window_state = :maximized
      end
    end

    it 'should default to window state normal when not specified' do
      extra_session.should_receive(:WindowState=).with(1)
      extra.connect
    end

    it 'should default to being visible' do
      extra_session.should_receive(:Visible=).with(true)
      extra.connect
    end

    it 'should get the screen for the active session' do
      extra_session.should_receive(:Screen).and_return(extra_screen)
      extra.connect
    end

    it 'should get the area from the screen' do
      extra_screen.should_receive(:SelectAll).and_return(extra_area)
      extra.connect
    end

    it 'should disconnect from a session' do
      extra_session.should_receive(:Close)
      extra_system.should_receive(:Quit)
      extra.connect
      extra.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      extra_screen.should_receive(:GetString).with(1, 2, 10).and_return('blah')
      extra.connect
      extra.get_string(1, 2, 10).should == 'blah'
    end

    it 'should put the value on the screen' do
      wait_collection = double('wait')
      extra_screen.should_receive(:PutString).with('blah', 1, 2)
      extra_screen.should_receive(:WaitHostQuiet).and_return(wait_collection)
      wait_collection.should_receive(:Wait).with(1000)
      extra.connect
      extra.put_string('blah', 1, 2)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      wait_collection = double('wait')
      extra_screen.should_receive(:SendKeys).with('<Clear>')
      extra_screen.should_receive(:WaitHostQuiet).and_return(wait_collection)
      wait_collection.should_receive(:Wait).with(1000)
      extra.connect
      extra.send_keys(TE3270.Clear)
    end

    it 'should wait for a string to appear' do
      wait_col = double('wait')
      extra_screen.should_receive(:WaitForString).with('The String', 3, 10).and_return(wait_col)
      extra_system.should_receive(:TimeoutValue).and_return(30000)
      wait_col.should_receive(:Wait).with(30000)
      extra.connect
      extra.wait_for_string('The String', 3, 10)
    end

    it 'should wait for the host to be quiet' do
      wait_col = double('wait')
      extra_screen.should_receive(:WaitHostQuiet).and_return(wait_col)
      wait_col.should_receive(:Wait).with(4000)
      extra.connect
      extra.wait_for_host(4)
    end

    it 'should wait until the cursor is at a position' do
      extra_screen.should_receive(:WaitForCursor).with(5, 8)
      extra.connect
      extra.wait_until_cursor_at(5, 8)
    end

    it 'should take screenshots' do
      take = double('Take')
      extra_session.should_receive(:WindowHandle).and_return(123)
      Win32::Screenshot::Take.should_receive(:of).with(:window, hwnd: 123).and_return(take)
      take.should_receive(:write).with('image.png')
      extra.connect
      extra.screenshot('image.png')
    end

    it "should get the screen text" do
      extra_area.should_receive(:Value).and_return('blah')
      extra.connect
      extra.text.should == 'blah'
    end

  end
end