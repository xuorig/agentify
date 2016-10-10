require './test/test_helper'

class ReactorTest < Minitest::Test
  def setup
    @reactor = Agentify::Reactor.new
  end

  def test_add_event_listener_fires_callback_on_event
    callback = Proc.new {}
    callback.expects(:call)

    @reactor.add_event_listener(:test) { callback.call }
    @reactor.trigger(:test)

    @reactor.run_once
  end

  def test_add_event_listener_with_multiple_callbacks
    callback = Proc.new {}
    callback.expects(:call)

    other_callback = Proc.new {}
    other_callback.expects(:call)

    @reactor.add_event_listener(:test) { callback.call }
    @reactor.add_event_listener(:test) { other_callback.call }

    @reactor.trigger(:test)

    @reactor.run_once
  end

  def test_trigger_fires_the_callback_each_time
    callback = Proc.new {}
    callback.expects(:call).twice

    @reactor.add_event_listener(:test) { callback.call }

    @reactor.trigger(:test)
    @reactor.trigger(:test)

    @reactor.run_once
  end
end
