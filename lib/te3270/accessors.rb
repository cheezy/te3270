
module TE3270
  module Accessors

    def text_field(name, x, y, length, editable)
      define_method(name) do
        platform.get_text_field(x, y, length)
      end

      define_method("#{name}=") do |value|
        platform.put_text_field(value, x, y, length)
      end if editable
    end

  end
end
