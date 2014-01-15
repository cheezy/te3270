require 'spec_helper'

class AccessorsTestScreen
  include TE3270

  text_field(:method_name, 1, 2, 10, true)
end

describe TE3270::Accessors do

  let(:screen_object) { AccessorsTestScreen.new }

  describe "text_field accessors" do

    it 'should generate a method to retrieve the value' do
      screen_object.should respond_to :method_name
    end

    it 'should generate a method to set the value' do
      screen_object.should respond_to :method_name=
    end

  end

end