require 'spec_helper'

class AccessorsTestScreen
  include TE3270

  text_field(:method_name, 1, 2, 10, true)
  text_field(:read_only, 2, 3, 12, false)
end

describe TE3270::Accessors do

  let(:platform) { double('platform') }
  let(:screen_object) { AccessorsTestScreen.new platform }

  before(:each) do
    screen_object.stub(:platform).and_return platform
  end

  describe "text_field accessors" do

    it 'should generate a method to retrieve the value' do
      screen_object.should respond_to :method_name
    end

    it 'should generate a method to set the value' do
      screen_object.should respond_to :method_name=
    end

    it 'should not generate a method to set the value if it is not editable' do
      screen_object.should_not respond_to :read_only=
    end

    it 'should use the platform to get the text value' do
      platform.should_receive(:get_text_field).with(1, 2, 10).and_return('abc')
      screen_object.method_name.should == 'abc'
    end

    it 'should use the platform to set the text value' do
      platform.should_receive(:put_text_field).with('abc', 1, 2)
      screen_object.method_name = 'abc'
    end

  end

end