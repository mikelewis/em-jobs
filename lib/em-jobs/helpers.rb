module EventMachine
  module Jobs
    module Helpers
      extend self

      def create_defferable(instance, information, meth, args)
        success_method, failure_method = information[:on_success], information[:on_failure]

        if args.last.is_a?(Hash) && (args.last.include?(:on_success) || args.last.include?(:on_failure))
          h = args.pop
          success_method = (h[:on_success] && [true, h[:on_success]])  || success_method
          failure_method = (h[:on_failure] && [true, h[:on_failure]])  || failure_method
        end

        success_callback, failure_callback = [success_method, failure_method].map do |callback|
          case callback
          when Symbol
            begin
            instance.method(callback)
            rescue NameError
              raise Exceptions::InvalidCallbackError.new("#{callback} is not a defined method for your callback.")
            end
          when Proc
            proc { |*results| instance.instance_exec(*results, &callback) }
          when Array
            callback[1]
          else # if not given
            proc { |*results| }
          end
        end

        defferable = Job.new(instance, meth, information[:defer], :succeed => success_callback, :fail => failure_callback )
        defferable.callback(&success_callback)
        defferable.errback(&failure_callback)

        defferable
      end
    end
  end
end

