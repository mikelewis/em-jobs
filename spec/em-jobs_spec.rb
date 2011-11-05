require 'spec_helper'

describe EventMachine::Jobs do
  context "integration" do
    before do
      @garage = ::Garage.new
    end

    it "should respond to sugar methods" do
      ["paint_car"].each do |meth|
        @garage.should respond_to("queue_#{meth}".to_sym)
      end
    end

    it "should respond to non sugar method" do
      @garage.should respond_to("queue_job".to_sym)
    end

    it "should not run a job in EM defer if it was specified" do
      EM.run do
        @garage.queue_paint_car("yellow")
      end

      thread, results = @garage.result
      Thread.current.should == thread
    end

  end
end
