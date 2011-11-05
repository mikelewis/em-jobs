module EventMachine
  module Jobs
    module Exceptions
      class UndefinedJob < NoMethodError; end
      class JobArgumentError < ArgumentError; end
      class InvalidCallbackError < StandardError; end
    end
  end
end
