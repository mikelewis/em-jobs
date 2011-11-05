module EventMachine
  module Jobs
    class Job
      include ::EM::Deferrable
      attr_accessor :channel, :defer

      def initialize(instance, method, defer)
        @instance, @method = instance, method
        instance_klass = (class << @instance; self; end)

        job_instance = self # need to store a reference to self as we are entering a different context below
        instance_klass.class_eval do
          [:succeed, :fail].each do |callback|
            define_method(callback) do |*args|
              job_instance.send(callback, *args) # now call job.succeed or job.fail which will trigger EM Deferrable Callback
            end
          end
        end
      end

      def job(*args)
        @instance.send(@method, *args)
      rescue ArgumentError => e
        raise Exceptions::JobArgumentError.new("You supplied job: #{@method} with the #{e.message}")
      end
    end
  end
end
