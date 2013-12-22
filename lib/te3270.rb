require 'te3270/version'
require 'te3270/emulators/extra'

module TE3270



  def platform
    @platform ||= Extra.new
  end
end
