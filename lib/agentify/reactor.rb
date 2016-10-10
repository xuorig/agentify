require 'thread'
require 'agentify/reactor/event_timer'

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

    def run_once
      wait

      execute_timers_if_needed

      until @queue.empty?
        event = @queue.pop

        listeners[event].each do |callback|
          callback.call
        end

        @timers[event].reset if @timers[event]
      end
    end

    def add_event_listener(event_name, &block)
      @listeners[event_name] << block
    end

    def add_timer(event, interval:)
      @timers[event] = EventTimer.new(event, interval)
    end

    def trigger(event_name)
      @queue << event_name
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
      return if @timers.empty?

      next_timer = @timers.values.map(&:next_execute).min - Time.now

      return 0 if next_timer < 0

      next_timer
    end

    def execute_timers_if_needed
      @timers.each { |event, timer| execute_timer(timer) }
    end

    def execute_timer(timer)
      return unless timer.should_execute?

      @queue << timer.event

      timer.last_fired = Time.now
    end

    def read_self_pipe_if_needed(ready_io)
      if ready_io && ready_io[0] && ready_io[0][0] == @self_pipe_reader
        @self_pipe_reader.read(1)
      end
    end

    def wakeup
      @self_pipe_writer.write_nonblock('!')
    end
  end
end
