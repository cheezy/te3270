require 'te3270/version'
require 'te3270/accessors'
require 'te3270/screen_factory'
require 'te3270/emulators/extra'

module TE3270

  def self.included(cls)
    cls.extend TE3270::Accessors
  end

  def platform
    @platform ||= Extra.new
  end

end
