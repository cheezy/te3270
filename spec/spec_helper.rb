$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
require 'win32ole'
require 'win32/screenshot'

def mock_system
  @mock_system ||= double('system')
  @mock_system.stub(:Sessions).and_return mock_sessions
  @mock_system
end

def mock_sessions
  @mock_sessions ||= double('sessions')
  @mock_sessions.stub(:Count).and_return 0
  @mock_sessions.stub(:Open).and_return mock_session
  @mock_sessions
end

def mock_session
  @mock_session ||= double('session')
  @mock_session.stub(:Screen).and_return mock_screen
  @mock_session.stub(:WindowState=)
  @mock_session.stub(:Visible=)
  @mock_session
end

def mock_screen
  @mock_screen ||= double('screen')
  @mock_screen.stub(:SelectAll).and_return mock_area
  @mock_screen
end

def mock_area
  @mock_area ||= double('area')
  @mock_area
end



