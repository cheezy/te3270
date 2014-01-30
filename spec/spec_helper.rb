$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
require 'win32ole'
require 'win32/screenshot'

def extra_system
  @extra_system ||= double('system')
  @extra_system.stub(:Sessions).and_return extra_sessions
  @extra_system.stub(:Version).and_return("0")
  @extra_system
end

def extra_sessions
  @extra_sessions ||= double('sessions')
  @extra_sessions.stub(:Count).and_return 0
  @extra_sessions.stub(:Open).and_return extra_session
  @extra_sessions
end

def extra_session
  @extra_session ||= double('session')
  @extra_session.stub(:Screen).and_return extra_screen
  @extra_session.stub(:WindowState=)
  @extra_session.stub(:Visible=)
  @extra_session
end

def extra_screen
  @extra_screen ||= double('screen')
  @extra_screen.stub(:SelectAll).and_return extra_area
  @extra_screen
end

def extra_area
  @extra_area ||= double('area')
  @extra_area
end

def quick_system
  @quick_system ||= double('quick_system')
  @quick_system.stub(:ActiveSession).and_return quick_session
  @quick_system.stub(:Visible=)
  @quick_system
end

def quick_session
  @quick_session ||= double('quick_session')
  @quick_session.stub(:Screen).and_return quick_screen
  @quick_session.stub(:Connect)
  @quick_session.stub(:Server_Name=)
  @quick_session
end

def quick_screen
  @quick_screen ||= double('screen')
  @quick_screen
end

