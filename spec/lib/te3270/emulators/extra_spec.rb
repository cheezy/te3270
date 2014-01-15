require 'spec_helper'

describe TE3270::Emulators::Extra do

  let(:extra) { TE3270::Emulators::Extra.new }

  before(:each) do
    WIN32OLE.stub(:connect).and_return mock_system
  end


  describe "global behaviors" do
    it 'should attempt to connect to an already running terminal' do
      WIN32OLE.should_receive(:connect).with('EXTRA.System').and_return(mock_system)
      extra.connect
    end

    it 'should start new terminal when one is not already running' do
      WIN32OLE.should_receive(:connect).and_raise "Error"
      WIN32OLE.should_receive(:new).and_return(mock_system)
      extra.connect
    end

    it 'should get the active session' do
      mock_system.should_receive(:ActiveSession).and_return(mock_session)
      extra.connect
    end

    it 'should get the screen for the active session' do
      mock_session.should_receive(:Screen).and_return(mock_screen)
      extra.connect
    end

    it 'should disconnect from a session' do
      mock_session.should_receive(:Close)
      extra.connect
      extra.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      mock_screen.should_receive(:GetString).with(1, 2, 10).and_return('blah')
      extra.connect
      extra.get_string(1, 2, 10).should == 'blah'
    end

    it 'should put the value on the screen' do
      mock_screen.should_receive(:PutString).with('blah', 1, 2)
      extra.connect
      extra.put_string('blah', 1, 2)
    end
  end
end