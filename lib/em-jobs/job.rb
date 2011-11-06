module EventMachine
  module Jobs
    class Job
      include ::EM::Deferrable
      attr_accessor :channel, :defer

      def initialize(instance, method, defer, defined_callbacks)
        @instance, @method, @defer, @defined_callbacks = instance, method, defer, defined_callbacks
      end

      def job(*args)
        callback = proc do |results|
          if results.is_a?(Array) && results.size >= 1
            type = results.shift
            type = :succeed if type == :success
            if @defined_callbacks[type]
              send(type, *results)
            end
          end
        end # will call succeed or fail for defferable
        op = proc { @instance.send(@method, *args) }
        if @defer
          EM.defer(op, callback)
        else
          results = op.call
          callback.call(results)
        end
      rescue ArgumentError => e
        raise Exceptions::JobArgumentError.new("You supplied job: #{@method} with the #{e.message}")
      rescue NoMethodError => e
        if e.name == @method
          raise Exceptions::UndefinedJob.new("You defined #{@method} as a job, but you have not created it yet.")
        else
          raise e
        end
      end
    end
  end
end
