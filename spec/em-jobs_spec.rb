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

    it "should raise an error if you try to call queue_x where x is not a valid job" do
      lambda do
        EM.run do
          @garage.queue_dancing
        end
      end.should raise_error(EventMachine::Jobs::Exceptions::UndefinedJob, "You called queue_dancing, however dancing is not a defined job.")
    end

    it "should raise an error if you try to call queue_job(x, *args) where x in a not a valid job" do
      lambda do
        EM.run do
          @garage.queue_job(:jumping, 20)
        end
      end.should raise_error(EventMachine::Jobs::Exceptions::UndefinedJob, "jumping is not a defined job.")
    end

    it "should raise an error if given a job with wrong arguments" do
      lambda do
        EM.run do
          @garage.queue_paint_car
        end
      end.should raise_error(EventMachine::Jobs::Exceptions::JobArgumentError, "You supplied job: paint_car with the wrong number of arguments (0 for 1)")
    end

    it "should raise an error when a callback(method) does not exist" do
      lambda do
        EM.run do
          @garage.queue_bad_job(2)
        end
      end.should raise_error(EventMachine::Jobs::Exceptions::InvalidCallbackError, "this_method_doesnt_exist is not a defined method for your callback.")
    end

    it "should raise an error when a job does not exist" do
      lambda do
        EM.run do
          @garage.queue_undefined_method
        end
      end.should raise_error(EventMachine::Jobs::Exceptions::UndefinedJob, "You defined undefined_method as a job, but you have not created it yet.")
    end

    it "should run a method without callbacks" do
      EM.run do
        @garage.queue_lone_job(3)
      end

      @garage.result[1].should == 6
    end

    context "defer" do
      it "should run a job in EM defer if it was specified" do
        EM.run do
          @garage.queue_install_engine(:mustang)
        end

        thread, results = @garage.result
        Thread.current.should_not == thread
      end

      it "should fail" do
        EM.run do
          @garage.queue_install_engine(:ford)
        end

        thread, results = @garage.result
        results.should == :bad
      end

      it "should succeed" do
        EM.run do
          @garage.queue_install_engine(:mustang)
        end

        thread, results = @garage.result
        results.should == :good
      end

    end

    context "non-defer" do
      it "should not run a job in EM defer if it wasnt specified" do
        EM.run do
          @garage.queue_paint_car("yellow")
        end

        thread, results = @garage.result
        Thread.current.should == thread
      end

      it "should fail" do
        EM.run do
          @garage.queue_paint_car("yellow")
        end

        thread, results = @garage.result
        results.should == :not_supported
      end

      it "should succeed" do
        EM.run do
          @garage.queue_paint_car("red")
        end

        thread, results = @garage.result
        results.should == 5
      end
    end
  end
end
