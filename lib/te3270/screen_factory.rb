require 'page_navigation'

module TE3270
  #
  # Module to facilitate to creating of screen objects in step definitions.  You
  # can make the methods below available to all of your step definitions by adding
  # this module to World.
  #
  # @example Making the ScreenFactory available to your step definitions
  #   World TE3270::ScreenFactory
  #
  # @example using a screen in a Scenario
  #   on MyScreen do |screen|
  #     screen.name = 'Cheezy'
  #   end
  #
  # If you plan to use the +navigate_to+ method you will need to ensure
  # you setup the possible routes ahead of time.  You must always have
  # a default route in order for this to work.  Here is an example of
  # how you define routes:
  #
  # @example Example routes defined in env.rb
  #   TE3270::ScreenFactory.routes = {
  #     :default => [[ScreenOne,:method1], [ScreenTwo,:method2], [ScreenThree,:method3]],
  #     :another_route => [[ScreenOne,:method1, "arg1"], [ScreenTwo,:method2b], [ScreenThree,:method3]]
  #   }
  #
  # Notice the first entry of :another_route is passing an argument
  # to the method.
  #
  module ScreenFactory
    include PageNavigation

    #
    # Create a screen object.  Also sets an instance variable +@current_screen
    #
    # @param [Class]  screen_class a class that has included the TE3270 module
    # @param [block]  an optional block to be called
    # @return [ScreenObject] the newly created screen object
    #
    def on(screen_class, &block)
      raise '@emulator instance variable must be available to use the ScreenFactory methods' unless @emulator
      return super(screen_class, &block) unless screen_class.ancestors.include? TE3270
      @current_screen = screen_class.new @emulator
      block.call @current_screen if block
      @current_screen
    end

  end
end