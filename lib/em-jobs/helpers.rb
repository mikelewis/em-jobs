module EventMachine
  module Jobs
    module Helpers
      extend self

      def create_defferable(instance, information, meth, args)
        success_method, failure_method = information[:on_success], information[:on_failure]

        success_callback, failure_callback = [success_method, failure_method].map do |callback|
          case callback
          when Symbol
            instance.method(callback)
          when Proc
            proc { |*results| instance.instance_exec(*results, &callback) }
          else # if not given
            proc { |*results| }
          end
        end

        defferable = Job.new(instance, meth, information[:defer])
        defferable.callback(&success_callback)
        defferable.errback(&failure_callback)

        defferable
      end
    end
  end
end

