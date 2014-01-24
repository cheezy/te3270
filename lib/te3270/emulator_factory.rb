require 'te3270/emulators/extra'

module TE3270
  module EmulatorFactory

    EMULATORS = {
        extra: TE3270::Emulators::Extra
    }

    def self.emulator_for(platform)
      EMULATORS[platform]
    end

  end
end