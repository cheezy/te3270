$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
require 'win32ole'


def mock_system
  @mock_system ||= double('system')
  @mock_system.stub(:ActiveSession).and_return mock_session
  @mock_system
end

def mock_session
  @mock_session ||= double('session')
  @mock_session.stub(:Screen).and_return mock_screen
  @mock_session
end

def mock_screen
  @mock_screen ||= double('screen')
end



