require 'spec_helper'

describe TE3270::Emulators::Quick3270 do

  let(:quick) { TE3270::Emulators::Quick3270.new }

  before(:each) do
    WIN32OLE.stub(:connect).and_return quick_system
  end

  describe "global behaviors" do
    it 'should attempt to connect to an already running terminal' do
      WIN32OLE.should_receive(:connect).with('Quick3270.Application').and_return(quick_system)
      quick.connect
    end

    it 'should start new terminal when one is not already running' do
      WIN32OLE.should_receive(:connect).and_raise "Error"
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

    it 'should default to Visible being true when not provided' do
      quick_system.should_receive(:Visible=).with(true)
      quick.connect
    end

    it 'should make the connection via the session' do
      quick_session.should_receive(:Connect)
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
end