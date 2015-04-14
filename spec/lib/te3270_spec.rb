require 'spec_helper'

class TEScreenObject
  include TE3270

  attr_reader :initialize_screen

  def initialize_screen
    @initialize_screen = true
  end
end

describe TE3270 do
  let(:platform) { double('platform') }
  let(:screen_object) { TEScreenObject.new platform }

  before(:each) do
    screen_object.stub(:platform).and_return platform
  end

  describe "interacting with the platform" do
    it 'should use the platform to connect to an emulator' do
      platform.should_receive(:connect)
      screen_object.connect
    end

    it 'should use the platform to disconnect from an emulator' do
      platform.should_receive(:disconnect)
      screen_object.disconnect
    end

    it 'should use the platform to send keys to the screen' do
      platform.should_receive(:send_keys).with('<Clear>')
      screen_object.send_keys(TE3270.Clear)
    end

    it 'should use the platform to wait for a string to appear on the screen' do
      platform.should_receive(:wait_for_string).with('The String', 2, 4)
      screen_object.wait_for_string('The String', 2, 4)
    end

    it 'should use the platform to wait for the host to be quiet' do
      platform.should_receive(:wait_for_host).with(4)
      screen_object.wait_for_host(4)
    end

    it 'should default to five seconds when waiting for the host' do
      platform.should_receive(:wait_for_host).with(5)
      screen_object.wait_for_host
    end

    it 'should use the platform to wait until the cursor at a specific position' do
      platform.should_receive(:wait_until_cursor_at).with(10, 10)
      screen_object.wait_until_cursor_at(10, 10)
    end

    it 'should use the platform to take a screenshot of the screen' do
      platform.should_receive(:screenshot).with('image.png')
      screen_object.screenshot('image.png')
    end

    it 'should use the platform to get the text for the entire screen' do
      platform.should_receive(:text).and_return('123abc')
      screen_object.text.should == '123abc'
    end
  end

  describe "module functionality" do
    it 'should know the function keys' do
      TE3270.Clear.should == '<Clear>'
      TE3270.Pf24.should == '<Pf24>'
    end

    it 'should call initialize_screen if it exists' do
      screen_object.initialize_screen.should be true
    end

    it 'should create an emulator and connect to terminal' do
      TE3270::Emulators::Extra.should_receive(:new).and_return(platform)
      platform.should_receive(:connect)
      TE3270.emulator_for :extra
    end

    it 'should accept a block when creating an emulator' do
      WIN32OLE.stub(:new).and_return extra_system
      extra_sessions.should_receive(:Open).with('blah.edp').and_return(extra_session)
      TE3270.emulator_for :extra do |emulator|
        emulator.session_file = 'blah.edp'
      end
    end

    it 'should allow one to disconnect using the module' do
      platform.should_receive(:disconnect)
      TE3270.disconnect(platform)
    end
  end

end
