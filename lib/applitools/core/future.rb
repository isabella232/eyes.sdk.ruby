# frozen_string_literal: true

module Applitools
  class Future
    attr_accessor :result, :semaphore, :block, :thread, :description

    def initialize(semaphore, description = nil, &block)
      raise Applitools::EyesIllegalArgument, 'Applitools::Future must be initialized with a block' unless block_given?
      self.block = block
      self.semaphore = semaphore
      self.description = description
      self.thread = Thread.new do
        begin
          self.result = yield(semaphore)
        rescue StandardError => e
          Applitools::EyesLogger.logger.error 'Failed to execute future'
          Applitools::EyesLogger.logger.error e.message
          Applitools::EyesLogger.logger.error e.backtrace.join(' ')
        end
      end
    end

    def get
      thread.join(350)
      raise Applitools::EyesError, "Failed to execute future - got nil result! (#{description})" if result.nil?
      result
    end
  end
end
