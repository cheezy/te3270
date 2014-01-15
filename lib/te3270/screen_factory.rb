require 'page_navigation'

module TE3270
  module ScreenFactory
    include PageNavigation

    def on(screen_class, &block)
      @current_screen = screen_class.new
      block.call @current_screen if block
      @current_screen
    end

  end
end