$:.unshift File.dirname(__FILE__) + '/../lib'
require 'em-jobs'

class Garage
  include EM::Jobs
  setup_job :paint_car, :on_success => :painted_car,
    :on_failure => lambda {|reason|  set_result_and_quit(reason) }

  setup_job :bad_job, :on_success => :this_method_doesnt_exist

  setup_job :lone_job

  setup_job :undefined_method

  setup_job :install_engine, :on_success => lambda {|result| set_result_and_quit(:awesome); nil},
    :on_failure => :failed_engine, :defer => true

  setup_job :install_brakes, :defer => true

  setup_job :jump, :defer => true

  setup_job :crouch, :defer => true

  attr_accessor :result

  def initialize
    @result = nil
    @thread = Thread.current
  end

  def jump(type)
    sleep 2
    return :success, :yes if type == :mustang
    [:fail, :no]
  end

  def crouch(type)
    sleep 1
    return :success, :yes if type == :mustang
    [:fail, :no]
  end

  def install_brakes(type)
    return :success, :yes if type == :mustang
    [:fail, :no]
  end

  def install_engine(type)
    @thread = Thread.current
    if type == :ford
      return :fail, :bad
    else
      return :success, :good
    end
  end

  def failed_engine(results)
    set_result_and_quit(:crap)
    nil
  end

  def lone_job(input)
    if input.is_a? Symbol
      return [:success, 5]
    else
      set_result_and_quit(input + 3)
      nil
    end
  end

  def failed_engine(result)
    set_result_and_quit(result)
    nil
  end

  def bad_job(num)
    if num > 3
      return :fail, :too_high
    else
      return :success, :awesome
    end
  end

  def paint_car(color)
    if color == "red"
      return :success, 5
    else
      return :fail, :not_supported
    end
  end

  def painted_car(cost)
    set_result_and_quit(cost)
  end

  def set_result_and_quit(result)
    @result = [@thread, result]
    EM.stop
  end

end

