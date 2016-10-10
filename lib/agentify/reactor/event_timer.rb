module Agentify
  class Reactor
    class EventTimer
      attr_reader(:event, :next_execute)
      attr_accessor(:last_fired)

      def initialize(event, interval)
        @event = event
        @interval = interval
        @next_execute = Time.now + interval
        @last_fired = nil
      end

      def should_execute?
        Time.now >= @next_execute
      end

      def reset
        now = Time.now

        @next_execute = now unless @interval

        execute_time = last_fired || now

        while execute_time <= now
          execute_time += @interval
        end

        @next_execute = execute_time
      end
    end
  end
end
