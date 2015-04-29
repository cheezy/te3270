if Gem.win_platform?

  require 'spec_helper'

  describe TE3270::Emulators::Quick3270 do

    let(:quick) { TE3270::Emulators::Quick3270.new }

    before(:each) do
      WIN32OLE.stub(:new).and_return quick_system
      quick.instance_variable_set(:@session_file, 'the_host')
    end

    describe "global behaviors" do
      it 'should start new terminal' do
        WIN32OLE.should_receive(:new).and_return(quick_system)
        quick.connect
      end

      it 'should establish a session' do
        quick_system.should_receive(:ActiveSession).and_return(quick_session)
        quick.connect
      end

      it 'should get the screen from the active session' do
        quick_session.should_receive(:Screen).and_return(quick_screen)
        quick.connect
      end

      it 'should take the Visible value from a block' do
        quick_system.should_receive(:Visible=).with(false)
        quick.connect do |platform|
          platform.visible = false
        end
      end

      it 'should take the session file from a block' do
        quick.should_receive(:session_file=).with('blah.txt')
        quick.connect do |platform|
          platform.session_file = 'blah.txt'
        end
      end

      it 'should display an error when the session file is not set' do
        quick.instance_variable_set(:@session_file, nil)
        expect { quick.connect }.to raise_error('The session file must be set in a block when calling connect with the Quick3270 emulator.')
      end

      it 'should open the connection using the sesion file' do
        quick_session.should_receive(:Open).with('blah.txt')
        quick.connect do |platform|
          platform.session_file = 'blah.txt'
        end
      end

      it 'should default to Visible being true when not provided' do
        quick_system.should_receive(:Visible=).with(true)
        quick.connect
      end

      it 'should make the connection via the session' do
        quick_session.should_receive(:Connect)
        quick.connect
      end

      it 'should check to make sure the connection is successful before continuing' do
        quick_session.should_receive(:Connected).once.and_return(false)
        quick_screen.should_receive(:WaitHostQuiet).once.with(1000)
        quick_session.should_receive(:Connected).once.and_return(true)
        quick.connect
      end

      it 'should disconnect from a session' do
        application = double('application')
        quick_session.should_receive(:Disconnect)
        quick_system.should_receive(:Application).and_return(application)
        application.should_receive(:Quit)
        quick.connect
        quick.disconnect
      end
    end

    describe "interacting with text fields" do
      it 'should get the value from the screen' do
        quick_screen.should_receive(:GetString).with(1, 2, 7).and_return('blah')
        quick.connect
        quick.get_string(1, 2, 7).should == 'blah'
      end

      it 'should put a value on the screen' do
        quick_screen.should_receive(:MoveTo).with(15, 56)
        quick_screen.should_receive(:PutString).with('blah')
        quick_screen.should_receive(:WaitHostQuiet).with(3000)
        quick.connect
        quick.put_string('blah', 15, 56)
      end
    end

    describe "interacting with the screen" do
      it 'should know how to send function keys' do
        quick_screen.should_receive(:SendKeys).with('<Home>')
        quick_screen.should_receive(:WaitHostQuiet).with(3000)
        quick.connect
        quick.send_keys(TE3270.Home)
      end

      it 'should wait for a string to appear' do
        quick_screen.should_receive(:WaitForString).with('string', 3, 10)
        quick.connect
        quick.wait_for_string('string', 3, 10)
      end

      it 'should wait for the host to be quiet' do
        quick_screen.should_receive(:WaitHostQuiet).with(6000)
        quick.connect
        quick.wait_for_host(6)
      end

      it 'should wait until the cursor is at a position' do
        quick_screen.should_receive(:WaitForCursor).with(5, 8)
        quick.connect
        quick.wait_until_cursor_at(5,8)
      end

      it 'should take screenshots' do
        take = double('Take')
        quick_system.should_receive(:WindowTitle).and_return('The Title')
        Win32::Screenshot::Take.should_receive(:of).with(:window, title: 'The Title').and_return(take)
        take.should_receive(:write).with('image.png')
        quick.connect
        quick.screenshot('image.png')
      end

      it 'should delete the file for the screenshot if it already exists' do
        File.should_receive(:exists?).and_return(true)
        File.should_receive(:delete)
        take = double('Take')
        quick_system.should_receive(:WindowTitle).and_return('The Title')
        Win32::Screenshot::Take.should_receive(:of).with(:window, title: 'The Title').and_return(take)
        take.should_receive(:write).with('image.png')
        quick.connect
        quick.screenshot('image.png')
      end

      it 'should make the window visible before taking a screenshot' do
        take = double('Take')
        quick_system.should_receive(:WindowTitle).and_return('The Title')
        Win32::Screenshot::Take.should_receive(:of).with(:window, title: 'The Title').and_return(take)
        take.should_receive(:write).with('image.png')
        quick_system.should_receive(:Visible=).once.with(true)
        quick_system.should_receive(:Visible=).twice.with(false)
        quick.connect do |emulator|
          emulator.visible = false
        end
        quick.screenshot('image.png')
      end

      it 'should get the screen text' do
        quick_screen.should_receive(:Rows).and_return(3)
        quick_screen.should_receive(:Cols).and_return(10)
        3.times do |time|
          quick_screen.should_receive(:GetString).with(time+1, 1, 10).and_return("row #{time}")
        end
        quick.connect
        quick.text.should == 'row 0\nrow 1\nrow 2\n'
      end
    end
  end

end
