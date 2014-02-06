
module TE3270
  module Accessors

    #
    # adds two methods to the screen object - one to set text in a text field,
    # another to retrieve text from a text field.
    #
    # @example
    #   text_field(:first_name, 23,45,20)
    #   # will generate 'first_name', 'first_name=' method
    #
    # @param  [String] the name used for the generated methods
    # @param [FixedNum] row number of the location
    # @param [FixedNum] column number of the location
    # @param [FixedNum] length of the text field
    # @param [true|false] editable is by default true
    #

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
