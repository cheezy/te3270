$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
require 'win32ole'


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
  @mock_session
end

def mock_screen
  @mock_screen ||= double('screen')
end



