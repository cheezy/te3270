require 'spec_helper'

describe TE3270::Emulators::Extra do

  let(:extra) { TE3270::Emulators::Extra.new }

  describe "global behaviors" do
    before(:each) do
      WIN32OLE.stub(:connect).and_return mock_system
    end

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
end