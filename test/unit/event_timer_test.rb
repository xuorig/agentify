require './test/test_helper'

class EventTimerTest < Minitest::Test
  def setup
    @timer = Agentify::Reactor::EventTimer
  end
end
