$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'te3270'
if Gem.win_platform?
  require 'win32ole'
  require 'win32/screenshot'
end


def extra_system
  @extra_system ||= double('system')
  allow(@extra_system).to receive(:Sessions).and_return extra_sessions
  allow(@extra_system).to receive(:Version).and_return("0")
  @extra_system
end

def extra_sessions
  @extra_sessions ||= double('sessions')
  allow(@extra_sessions).to receive(:Count).and_return 0
  allow(@extra_sessions).to receive(:Open).and_return extra_session
  @extra_sessions
end

def extra_session
  @extra_session ||= double('session')
  allow(@extra_session).to receive(:Screen).and_return extra_screen
  allow(@extra_session).to receive(:WindowState=)
  allow(@extra_session).to receive(:Visible=)
  @extra_session
end

def extra_screen
  @extra_screen ||= double('screen')
  allow(@extra_screen).to receive(:SelectAll).and_return extra_area
  @extra_screen
end

def extra_area
  @extra_area ||= double('area')
  @extra_area
end

def quick_system
  @quick_system ||= double('quick_system')
  allow(@quick_system).to receive(:ActiveSession).and_return quick_session
  allow(@quick_system).to receive(:Visible=)
  @quick_system
end

def quick_session
  @quick_session ||= double('quick_session')
  allow(@quick_session).to receive(:Screen).and_return quick_screen
  allow(@quick_session).to receive(:Open)
  allow(@quick_session).to receive(:Connect)
  allow(@quick_session).to receive(:Server_Name=)
  allow(@quick_session).to receive(:Connected).and_return true
  @quick_session
end

def quick_screen
  @quick_screen ||= double('screen')
  @quick_screen
end

def x3270_system
  @x3270_system ||= double('x3270_system')
  @x3270_system
end
