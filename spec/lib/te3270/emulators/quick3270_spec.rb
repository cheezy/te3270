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
  end
end