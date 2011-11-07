$:.unshift File.dirname(__FILE__) + '/../lib'
require 'em-jobs'
require 'prime'

class Calculator
  include EM::Jobs

  setup_job :multiply, :on_failure => proc {|result| puts result}
  setup_job :slow_is_prime?, :on_success => :yes_prime, :on_failure => :no_prime # this is slow because we dont use defer
  setup_job :fast_is_prime?, :defer => true, :on_success => :yes_prime, :on_failure => :no_prime

  def initialize(*nums)
    @nums = nums
  end

  def multiply
    result = @nums.inject(1){|memo, num| memo * num}

    if result <= 0
      return :fail, "You cant go below zero!"
    else
      return :success, result
    end
  end

  def slow_is_prime?(num)
    sleep 3 # pretend we are working
    callback = Prime.prime?(num) ? :success : :fail
    return callback, num
  end

  def fast_is_prime?(num)
    sleep 3 # pretend we are working
    callback = Prime.prime?(num) ? :success : :fail
    return callback, num
  end

  def yes_prime(num)
    puts "#{num} is prime!"
  end

  def no_prime(num)
    puts "#{num} is not prime!"
  end
end

EM.run do
  calc = Calculator.new(1,2,3)
  calc.queue_multiply(:on_success => proc {|result| puts "GOT #{result}!"})


  # this will take 9 seconds total
  [15,20, 7].each do |num|
    calc.queue_slow_is_prime?(num) # this is slow because we dont use defer
  end

    # takes 3 seconds total
    [15, 20, 7].each do |num|
      calc.queue_fast_is_prime?(num)
    end
end
