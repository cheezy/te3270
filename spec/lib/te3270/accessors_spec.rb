require 'spec_helper'

class AccessorsTestScreen
  include TE3270

  text_field(:method_name, 1, 2, 10, true)
  text_field(:read_only, 2, 3, 12, false)
  text_field(:default_editable, 3, 4, 14)
end

describe TE3270::Accessors do

  let(:platform) { double('platform') }
  let(:screen_object) { AccessorsTestScreen.new platform }

  before(:each) do
    allow(screen_object).to receive(:platform).and_return platform
  end

  describe "text_field accessors" do

    it 'should generate a method to retrieve the value' do
      expect(screen_object).to respond_to(:method_name)
    end

    it 'should generate a method to set the value' do
      expect(screen_object).to respond_to(:method_name=)
    end

    it 'should not generate a method to set the value if it is not editable' do
      expect(screen_object).not_to respond_to(:read_only=)
    end

    it 'should default to being editable when it is not specified' do
      expect(screen_object).to respond_to :default_editable=
    end

    it 'should use the platform to get the text value' do
      expect(platform).to receive(:get_string).with(1, 2, 10).and_return('abc')
      expect(screen_object.method_name).to eql 'abc'
    end

    it 'should use the platform to set the text value' do
      expect(platform).to receive(:put_string).with('abc', 1, 2)
      screen_object.method_name = 'abc'
    end

  end

end