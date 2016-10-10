require 'threading'

module Agentify
  class Bucket
    def initialize(max_size:)
      @bucket = []
      @lock = Mutex.new
      @max_size = max_size
    end

    def consume
      @lock.synchronize do
        result = @bucket
        @bucket = []
        result
      end
    end

    def add(data)
      @lock.synchronize do
        return if full?

        @bucket << data
      end
    end

    private

    def full?
      @bucket.size >= @max_size
    end
  end
end
