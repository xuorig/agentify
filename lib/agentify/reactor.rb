require 'thread'

module Agentify
  class Reactor
    def initialize
      @self_pipe_reader, @self_pipe_writer = IO.pipe
      @queue = Queue.new

      @listeners = Hash.new { |h,k| h[k] = [] }
      @timers = {}
    end

    def run
      loop do
        run_once
      end
    end

    def add_event_listener(event_name, &block)
      listeners[event_name] << &block
    end

    def add_timer(event, interval:)
      timers[event] = EventTimer.new(event, interval)
    end

    def trigger(event_name)
      queue << event_name
      wakeup
    end

    private

    attr_reader(
      :self_pipe_reader,
      :self_pipe_writer,
      :queue,
      :listeners,
      :timers
    )

    def run_once
      wait

      fire_timers_if_needed

      until event_queue.empty?
        event = queue.pop

        listeners[event].each do |callback|
          callback.call
        end

        reset_timer_for_event(event)
      end
    end

    def wait
      ready = IO.select(
        [self_pipe_reader],
        nil,
        nil,
        calculate_next_timer
      )

      read_self_pipe_if_needed(ready)
    end

    def calculate_next_timer
      #TODO when is the next timer ready to fire ?
    end

    def read_self_pipe_if_needed(ready_io)
      if ready_io && ready_io[0] && ready_io[0][0] == self_pipe_reader
        self_pipe_reader.read(1)
      end
    end

    def wakeup
      self_pipe_writter.write_nonblock('!')
    end
  end
end
