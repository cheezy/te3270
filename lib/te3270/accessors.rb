
module TE3270
  module Accessors

    def text_field(name, row, column, length, editable=true)
      define_method(name) do
        platform.get_string(row, column, length)
      end

      define_method("#{name}=") do |value|
        platform.put_string(value, row, column)
      end if editable
    end

  end
end
