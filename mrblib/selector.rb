module Rakie
  class Selector
    @instance = nil

    READ_EVENT = 1
    WRITE_EVENT = 2

    HANDLE_FAILED = -1
    HANDLE_CONTINUED = 0
    HANDLE_FINISHED = 1

    OPERATION_ADD = 0
    OPERATION_MODIFY = 1
    OPERATION_DELETE = 2

    def initialize
      @wait_ios = []
      @signal_in, @signal_out = IO.pipe
      @ios = {
        @signal_in => READ_EVENT
      }
      @handlers = {}
    end
    
    def process_signal(io)
      signal = io.read(1)

      if signal == 'q'
        return 1
      end

      operation, new_io, new_handler, new_event = @wait_ios.shift
      if new_io.closed?
        return 0
      end

      Log.debug("Event handling #{signal} with #{new_io.fileno} to #{new_event}")

      if operation == OPERATION_ADD
        @ios[new_io] = new_event
        @handlers[new_io] = new_handler
        Log.debug("Event add all #{new_io.fileno} to #{new_event}")

      elsif operation == OPERATION_DELETE
        handler = @handlers[new_io]

        if handler != nil
          Log.debug("Event close #{new_io}")
          handler.on_detach(new_io)
        end

        @ios.delete(new_io)
        @handlers.delete(new_io)
        Log.debug("Event remove all #{new_io}")

      elsif operation == OPERATION_MODIFY
        @ios[new_io] = new_event
        @handlers[new_io] = new_handler
        Log.debug("Event modify all #{new_io.fileno} to #{new_event}")
      end

      return 0
    end

    def run
      read_ios = @ios.select {|k, v| v & READ_EVENT > 0}
      write_ios = @ios.select {|k, v| v & WRITE_EVENT > 0}

      Log.debug("Event selecting ...")
      read_ready, write_ready = IO.select(read_ios.keys, write_ios.keys, [], 1)

      if read_ready != nil
        read_ready.each do |io|
          Log.debug("Event selecting ...")

          if io == @signal_in
            if self.process_signal(io) != 0
              return
            end

            next
          end

          handler = @handlers[io]

          if handler == nil
            next
          end

          result = handler.on_read(io)

          if result == HANDLE_FINISHED
            @ios[io] &= ~READ_EVENT
            Log.debug("Event remove read #{io}")

          elsif result == HANDLE_FAILED
            handler.on_detach(io)
            Log.debug("Event close #{io}")

            @ios.delete(io)
            @handlers.delete(io)
            Log.debug("Event remove all #{io}")
          end
        end
      end

      if write_ready != nil
        write_ready.each do |io|
          handler = @handlers[io]

          if handler == nil
            next
          end

          result = handler.on_write(io)

          if result == HANDLE_FINISHED
            @ios[io] &= ~WRITE_EVENT
            Log.debug("Event remove write #{io}")

          elsif result == HANDLE_FAILED
            handler.on_detach(io)
            Log.debug("Event close #{io}")

            @ios.delete(io)
            @handlers.delete(io)
            Log.debug("Event remove all #{io}")
          end
        end
      end
    end

    def push(io, handler, event)
      @wait_ios.push([OPERATION_ADD, io, handler, event])
      @signal_out.write('a')
    end

    def delete(io)
      @wait_ios.push([OPERATION_DELETE, io, nil, nil])
      @signal_out.write('a')
    end

    def modify(io, handler, event)
      @wait_ios.push([OPERATION_MODIFY, io, handler, event])
      @signal_out.write('a')
    end

    def self.instance
      @instance ||= Selector.new
    end

    def self.push(io, listener, type)
      self.instance.push(io, listener, type)
    end

    def self.delete(io)
      self.instance.delete(io)
    end

    def self.modify(io, listener, type)
      self.instance.modify(io, listener, type)
    end

    def self.select
      self.instance.run
    end
  end
end