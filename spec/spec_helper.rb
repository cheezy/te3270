$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
require 'win32ole'
require 'win32/screenshot'

def extra_system
  @mock_system ||= double('system')
  @mock_system.stub(:Sessions).and_return extra_sessions
  @mock_system
end

def extra_sessions
  @mock_sessions ||= double('sessions')
  @mock_sessions.stub(:Count).and_return 0
  @mock_sessions.stub(:Open).and_return extra_session
  @mock_sessions
end

def extra_session
  @mock_session ||= double('session')
  @mock_session.stub(:Screen).and_return extra_screen
  @mock_session.stub(:WindowState=)
  @mock_session.stub(:Visible=)
  @mock_session
end

def extra_screen
  @mock_screen ||= double('screen')
  @mock_screen.stub(:SelectAll).and_return extra_area
  @mock_screen
end

def extra_area
  @mock_area ||= double('area')
  @mock_area
end



