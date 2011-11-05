$:.unshift File.dirname(__FILE__) + '/../lib'
require 'em-jobs'

class Garage
  include EM::Jobs
  setup_job :paint_car, :on_success => :painted_car,
    :on_failure => lambda {|reason|  set_result_and_quit(reason) }

  setup_job :bad_job, :on_success => :this_method_doesnt_exist

  attr_accessor :result

  def initialize
    @result = nil
  end

  def bad_job(num)
    if num > 3
      fail(:too_high)
    else
      succeed(:awesome)
    end
  end

  def paint_car(color)
    if color == "red"
      succeed(5)
    else
      fail(:not_supported)
    end
  end

  def painted_car(cost)
    set_result_and_quit(cost)
  end

  def set_result_and_quit(result)
    @result = [Thread.current, result]
    EM.stop
  end

end
