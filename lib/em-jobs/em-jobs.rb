module EventMachine
  module Jobs
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        @__job_defferables__ = {}
      end
      base.extend(ClassMethods)
    end

    module InstanceMethods
      # instance method
      def job_queue
        @@queue ||= EM::Queue.new
      end

      def queue_job(meth, *args)
        meth = meth.to_sym
        defferable_information = self.class.__job_defferables__[meth]

        # Handle nil
        unless defferable_information
          raise "Invalid job name! Please define one in the class declaration"
        end

        defferable = Helpers.create_defferable(self, defferable_information, meth, args)
        job_queue.push(defferable)
        job_queue.pop do |d|
          d.job(*args)
        end
      end
    end

    module ClassMethods
      def __job_defferables__
        @__job_defferables__
      end

      def setup_job(method, opts={})
        self.class_eval do
          define_method("queue_" + method.to_s) do |*args|
            queue_job(method, *args)
          end
        end
        @__job_defferables__[method] = {:job_method => method.to_sym}.merge(opts)
      end

    end
  end
end
