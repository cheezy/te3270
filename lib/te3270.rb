require 'te3270/version'
require 'win32ole'
require 'emulators/extra'

module TE3270

  attr_reader :platform

  def initialize
    @platform = Extra.new
  end
end
