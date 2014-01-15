
module TE3270
  module Accessors

    def text_field(name, row, column, length, editable)
      define_method(name) do
        platform.get_text_field(row, column, length)
      end

      define_method("#{name}=") do |value|
        platform.put_text_field(value, row, column)
      end if editable
    end

  end
end
