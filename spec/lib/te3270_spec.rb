require 'spec_helper'

class TEScreenObject
  include TE3270
end

describe TE3270 do
  let(:screen_object) { TEScreenObject.new }
  let(:platform) { double('platform') }

  before(:each) do
    screen_object.stub(:platform).and_return platform
  end

  it 'should have a version number' do
    TE3270::VERSION.should_not be_nil
  end

  it 'should use the platform to connect to an emulator' do
    platform.should_receive(:connect)
    screen_object.connect
  end

  it 'should use the platform to disconnect from an emulator' do
    platform.should_receive(:disconnect)
    screen_object.disconnect
  end

  it 'should know the function keys' do
    TE3270.Clear.should == '<Clear>'
    TE3270.Pf24.should == '<Pf24>'
  end

  it 'should use the platform to send keys to the screen' do
    platform.should_receive(:send_keys).with('<Clear>')
    screen_object.send_keys(TE3270.Clear)
  end

  it 'should use the platform to wait for a string to appear on the screen' do
    platform.should_receive(:wait_for_string).with('The String')
    screen_object.wait_for_string('The String')
  end

  it 'should use the platform to wait for the host to be quiet' do
    platform.should_receive(:wait_for_host).with(4)
    screen_object.wait_for_host(4)
  end

  it 'should default to five seconds when waiting for the host' do
    platform.should_receive(:wait_for_host).with(5)
    screen_object.wait_for_host
  end
end
