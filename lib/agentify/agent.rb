require 'thread'

module Agentify
  class Agent
    def initialize
      @reactor = Reactor.new
    end

    def start
      run_reactor_in_thread
    end

    def stop
    end

    def every(interval, &block)
      event_name = make_event_name

      @reactor.add_event_listener(
        event_name,
        &block
      )

      @reactor.add_timer(event_name, interval: interval)
    end

    def on(event, &block)
      @reactor.add_event_listener(event, &block)
    end

    def trigger(event)
      @reactor.trigger(event)
    end

    private

    def run_reactor_in_thread
      Thread.new { reactor.run }
    end

    def make_event_name
      SecureRandom.base64.to_sym
    end
  end
end
