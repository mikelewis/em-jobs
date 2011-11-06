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

      def __defer_mutexes__
        @__defer_mutexes__ ||= {}
      end

      def queue_job(meth, *args)
        meth = meth.to_sym
        defferable_information = self.class.__job_defferables__[meth]

        unless defferable_information
          raise Exceptions::UndefinedJob.new("#{meth} is not a defined job.")
        end

        defferable = Helpers.create_defferable(self, defferable_information, meth, args)
        job_queue.push(defferable)
        job_queue.pop do |d|
          d.job(*args)
        end
      end

      def method_missing(meth, *args, &blk)
        if meth =~ /^queue_(.*)$/
          raise Exceptions::UndefinedJob.new("You called queue_#{$1}, however #{$1} is not a defined job.")
        else
          super
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

      def method_added(meth)
        if info = @__job_defferables__[meth]
          if info[:defer] && !info[:redefined_method]
            alias_method "old_unsynced_#{meth}", meth
            info[:redefined_method] = true
            self.class_eval do
              define_method(meth) do |*args, &blk|
              mutex = __defer_mutexes__[meth] ||= Mutex.new
              result = nil
              mutex.synchronize do
                send("old_unsynced_#{meth}", *args, &blk)
              end
              end
            end
          end
        end
        super
      end

    end
  end
end
