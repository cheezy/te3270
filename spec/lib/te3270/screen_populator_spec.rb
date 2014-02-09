require 'spec_helper'

class ScreenPopulatorScreen
  include TE3270

  text_field(:editable, 1, 2, 10, true)
  text_field(:read_only, 2, 3, 12, false)
end

describe TE3270::ScreenPopulator do

  let(:platform) { double('platform') }
  let(:screen_object) { ScreenPopulatorScreen.new platform }

  it 'should set a value in a text field' do
    platform.should_receive(:put_string).with('the_value', 1, 2)
    screen_object.populate_screen_with editable: 'the_value'
  end

  it 'should not set a value when a text field is read only' do
    platform.should_not_receive(:put_string)
    screen_object.populate_screen_with read_only: 'the_value'
  end

  it 'should attempt to set all values from the provided Hash' do
    platform.should_receive(:put_string).with('the_value', 1, 2)
    platform.should_not_receive(:put_string).with('read_only', 2, 3)
    screen_object.populate_screen_with(editable: 'the_value', read_only: 'read_only')
  end
end