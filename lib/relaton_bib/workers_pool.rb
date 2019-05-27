# frozen_string_literal: true

module RelatonBib
  # Workers poll.
  class WorkersPool
    attr_accessor :nb_hits

    def initialize(num_workers = 2)
      @num_workers = num_workers < 2 ? 2 : num_workers
      @queue = SizedQueue.new(num_workers * 2)
      @result = []
      @nb_hits = 0
    end

    def worker(&block)
      @threads = Array.new @num_workers do
        Thread.new do
          until (item = @queue.pop) == :END
            @result << yield(item) if block
          end
        end
      end
    end

    def result
      @threads.each(&:join)
      @result
    end

    def <<(item)
      @queue << item
      self
    end

    def end
      @num_workers.times { @queue << :END }
    end

    def size
      @result.size
    end
  end
end
