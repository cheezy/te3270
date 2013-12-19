require 'te3270/version'
require 'win32ole'
require 'emulators/extra'

module TE3270



  def platform
    @platform ||= Extra.new
  end
end
