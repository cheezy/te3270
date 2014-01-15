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
    world.on(ScreenFactoryScreen).should be_instance_of ScreenFactoryScreen
  end

  it 'should create a new screen object and execute a block' do
    world.on(ScreenFactoryScreen) do |page|
      page.should be_instance_of ScreenFactoryScreen
    end
  end
end