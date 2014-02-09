
module TE3270
  module ScreenPopulator

    def populate_screen_with(hsh)
      hsh.each do |key, value|
        self.send("#{key}=", value) if self.respond_to? "#{key}=".to_sym
      end
    end
  end
end