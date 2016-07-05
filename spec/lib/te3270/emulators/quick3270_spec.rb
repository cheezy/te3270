require 'spec_helper'

describe TE3270::Emulators::Quick3270 do

  unless Gem.win_platform?
    class WIN32OLE
    end
  end

  let(:quick) { TE3270::Emulators::Quick3270.new }

  before(:each) do
    allow(WIN32OLE).to receive(:new).and_return quick_system
    quick.instance_variable_set(:@session_file, 'the_host')
  end

  describe "global behaviors" do
    it 'should start new terminal' do
      expect(WIN32OLE).to receive(:new).and_return(quick_system)
      quick.connect
    end

    it 'should establish a session' do
      allow(quick_system).to receive(:ActiveSession).and_return(quick_session)
      quick.connect
    end

    it 'should get the screen from the active session' do
      expect(quick_session).to receive(:Screen).and_return(quick_screen)
      quick.connect
    end

    it 'should take the Visible value from a block' do
      expect(quick_system).to receive(:Visible=).with(false)
      quick.connect do |platform|
        platform.visible = false
      end
    end

    it 'should take the session file from a block' do
      expect(quick).to receive(:session_file=).with('blah.txt')
      quick.connect do |platform|
        platform.session_file = 'blah.txt'
      end
    end

    it 'should display an error when the session file is not set' do
      quick.instance_variable_set(:@session_file, nil)
      expect { quick.connect }.to raise_error('The session file must be set in a block when calling connect with the Quick3270 emulator.')
    end

    it 'should open the connection using the sesion file' do
      expect(quick_session).to receive(:Open).with('blah.txt')
      quick.connect do |platform|
        platform.session_file = 'blah.txt'
      end
    end

    it 'should default to Visible being true when not provided' do
      expect(quick_system).to receive(:Visible=).with(true)
      quick.connect
    end

    it 'should make the connection via the session' do
      expect(quick_session).to receive(:Connect)
      quick.connect
    end

    it 'should check to make sure the connection is successful before continuing' do
      expect(quick_session).to receive(:Connected).once.and_return(false)
      expect(quick_screen).to receive(:WaitHostQuiet).once.with(1000)
      expect(quick_session).to receive(:Connected).once.and_return(true)
      quick.connect
    end

    it 'should disconnect from a session' do
      application = double('application')
      expect(quick_session).to receive(:Disconnect)
      expect(quick_system).to receive(:Application).and_return(application)
      expect(application).to receive(:Quit)
      quick.connect
      quick.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      expect(quick_screen).to receive(:GetString).with(1, 2, 7).and_return('blah')
      quick.connect
      expect(quick.get_string(1, 2, 7)).to eql 'blah'
    end

    it 'should put a value on the screen' do
      expect(quick_screen).to receive(:MoveTo).with(15, 56)
      expect(quick_screen).to receive(:PutString).with('blah')
      expect(quick_screen).to receive(:WaitHostQuiet).with(3000)
      quick.connect
      quick.put_string('blah', 15, 56)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      expect(quick_screen).to receive(:SendKeys).with('<Home>')
      expect(quick_screen).to receive(:WaitHostQuiet).with(3000)
      quick.connect
      quick.send_keys(TE3270.Home)
    end

    it 'should wait for a string to appear' do
      expect(quick_screen).to receive(:WaitForString).with('string', 3, 10)
      quick.connect
      quick.wait_for_string('string', 3, 10)
    end

    it 'should wait for the host to be quiet' do
      expect(quick_screen).to receive(:WaitHostQuiet).with(6000)
      quick.connect
      quick.wait_for_host(6)
    end

    it 'should wait until the cursor is at a position' do
      expect(quick_screen).to receive(:WaitForCursor).with(5, 8)
      quick.connect
      quick.wait_until_cursor_at(5, 8)
    end

    if Gem.win_platform?

      it 'should take screenshots' do
        take = double('Take')
        expect(quick_system).to receive(:WindowTitle).and_return('The Title')
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, title: 'The Title').and_return(take)
        expect(take).to receive(:write).with('image.png')
        quick.connect
        quick.screenshot('image.png')
      end

      it 'should delete the file for the screenshot if it already exists' do
        expect(File).to receive(:exists?).and_return(true)
        expect(File).to receive(:delete)
        take = double('Take')
        expect(quick_system).to receive(:WindowTitle).and_return('The Title')
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, title: 'The Title').and_return(take)
        expect(take).to receive(:write).with('image.png')
        quick.connect
        quick.screenshot('image.png')
      end

      it 'should make the window visible before taking a screenshot' do
        take = double('Take')
        expect(quick_system).to receive(:WindowTitle).and_return('The Title')
        expect(Win32::Screenshot::Take).to receive(:of).with(:window, title: 'The Title').and_return(take)
        expect(take).to receive(:write).with('image.png')
        expect(quick_system).to receive(:Visible=).once.with(true)
        expect(quick_system).to receive(:Visible=).twice.with(false)
        quick.connect do |emulator|
          emulator.visible = false
        end
        quick.screenshot('image.png')
      end

    end

    it 'should get the screen text' do
      expect(quick_screen).to receive(:Rows).and_return(3)
      expect(quick_screen).to receive(:Cols).and_return(10)
      3.times do |time|
        expect(quick_screen).to receive(:GetString).with(time+1, 1, 10).and_return("row #{time}")
      end
      quick.connect
      expect(quick.text).to eql 'row 0\nrow 1\nrow 2\n'
    end
  end
end


