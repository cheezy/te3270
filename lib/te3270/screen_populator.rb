
module TE3270
  module ScreenPopulator

    #
    # This method will populate all matched screen text fields from the
    # Hash passed as an argument.  The way it find an element is by
    # matching the Hash key to the name you provided when declaring
    # the text field on your screen.
    #
    # @example
    #   class ExampleScreen
    #     include TE3270
    #
    #     text_field(:username, 1, 2, 20)
    #   end
    #
    #   ...
    #
    #   @emulator = TE3270::emulator_for :quick3270
    #   example_screen = ExampleScreen.new(@emulator)
    #   example_screen.populate_screen_with :username => 'a name'
    #
    # @param [Hash] hsh the data to use to populate this screen.
    #
    def populate_screen_with(hsh)
      hsh.each do |key, value|
        self.send("#{key}=", value) if self.respond_to? "#{key}=".to_sym
      end
    end

  end
end