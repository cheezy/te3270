require 'page_navigation'

module TE3270
  module ScreenFactory
    include PageNavigation

    def on(screen_class, &block)
      raise '@emulator instance variable must be available to use the ScreenFactory methods' unless @emulator
      @current_screen = screen_class.new @emulator
      block.call @current_screen if block
      @current_screen
    end

  end
end