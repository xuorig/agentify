require 'thread'

module Agentify
  class Agent
    def initialize
      @stopped = true
      @reactor = Reactor.new
    end

    def start
      @stopped = false
      run
    end

    def stop
      @stopped = true
    end

    def run
      Thread.new { reactor.run }
    end

    private

    attr_reader(:reactor)

    def stopped?
      @stopped
    end
  end
end
