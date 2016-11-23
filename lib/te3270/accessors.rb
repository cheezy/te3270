
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

    #
    # adds methods to get a row, set a row, find the location of a string, find and enter, and find the index of a
    # list_view
    # @example
    #   list_view(:menu_options, 23,1,20)
    #   # will generate 'menu_options_get_row', 'menu_options_set_row', 'menu_options_find_string',
    #   # "menu_options_empty?", "menu_options_has?", and "menu_options_find_index"
    # @param  [Symbol] the name used for the generated methods
    # @param [FixedNum] row number of the upper left corner of the list view being defined
    # @param [FixedNum] column number of the upper left corner of the list view being defined
    # @param [FixedNum] width of the list view in columns
    # @para  [FixedNum] height of the list view in rows
    # @param [true|false] editable is by default true
    #
    def list_view(name, row, column, width, height, editable=true)
      define_method(name) do
        (row...(row + height)).map do |current_row|
          platform.get_string(current_row, column, width).strip
        end
      end

      define_method("#{name}_get_row") do |index|
        platform.get_string((row + index), column, width)
      end

      define_method("#{name}_set_row") do |index, value|
        platform.put_string(value, row+index, column)
      end if editable

      define_method("#{name}_find_string") do |search_item, length, rel_x=0, rel_y=0|
        index = send("#{name}_find_index".to_sym, search_item)
        row_with_offset = row + index + rel_y
        column_with_offset = column + rel_x
        platform.get_string(row_with_offset, column_with_offset, length)
      end

      define_method("#{name}_empty?") do
        self.send(name).all?(&:empty?)
      end

      define_method("#{name}_has?") do |search_item|
        !!send("#{name}_find_index".to_sym, search_item)
      end

      define_method("#{name}_find_index") do |search_item|
        arr = send("#{name}".to_sym)
        arr.index {|row| row =~ /#{search_item}/ }
      end
    end

  end
end
