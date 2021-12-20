# require "fiber"
# require_relative "./selector"

module Rakie
  class Loop
    @instance = nil

    def initialize
      @tasks = []
      @wait = []
      @selector = Rakie::Selector.instance
      @started = false
    end

    def run(main)
      @started = true
      @tasks << main

      while @started
        @tasks += @wait
        @wait.clear

        @tasks.each do |task|
          unless task.alive?
            next
          end

          p "Running: #{task}"

          task.resume
        end

        @tasks.select! { |task| task.alive? }

        p Time.now

        Rakie::Selector.select
      end
    end

    def dispatch(task)
      @wait << task
    end

    def self.instance
      @instance ||= Loop.new
    end

    def self.dispatch
      task = Fiber.new { yield }
      self.instance.dispatch(task)
    end

    def self.run
      main = Fiber.new { loop { yield if block_given?; Fiber.yield } }
      self.instance.run(main)
    end
  end
end
