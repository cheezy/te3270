require 'spec_helper'

class ScreenFactoryScreen
  include TE3270
end

class World
  include TE3270::ScreenFactory
end

describe TE3270::ScreenFactory do

  let(:world) { World.new }

  it 'should create a new screen object' do
    emulator = double('platform')
    world.instance_variable_set('@emulator', emulator)
    world.on(ScreenFactoryScreen).should be_instance_of ScreenFactoryScreen
  end

  it 'should create a new screen object and execute a block' do
    emulator = double('platform')
    world.instance_variable_set('@emulator', emulator)
    world.on(ScreenFactoryScreen) do |page|
      page.should be_instance_of ScreenFactoryScreen
    end
  end

  it 'should raise an error when an @emulator instance variable does not exist' do
    expect { world.on(ScreenFactoryScreen) }.to raise_error("@emulator instance variable must be available to use the ScreenFactory methods")
  end
end