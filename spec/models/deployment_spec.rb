require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Deployment do
  describe 'attributes' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should have a deployable id' do
      @deployment.should respond_to(:deployable_id)
    end
    
    it 'should allow setting and retrieving the deployable id' do
      @deployment.deployable_id = 1
      @deployment.deployable_id.should == 1
    end
    
    it 'should have a host id' do
      @deployment.should respond_to(:host_id)
    end
    
    it 'should allow setting and retrieving the host id' do
      @deployment.host_id = 1
      @deployment.host_id.should == 1
    end
    
    it 'should have a reason' do
      @deployment.should respond_to(:reason)
    end
    
    it 'should allow setting and retrieving the reason' do
      @deployment.reason = 'initial deployment'
      @deployment.reason.should == 'initial deployment'
    end
    
    it 'should have a start time' do
      @deployment.should respond_to(:start_time)
    end
    
    it 'should allow setting and retrieving the start time' do
      @deployment.start_time = time = Time.now
      @deployment.start_time.should == time
    end
    
    it 'should have an end time' do
      @deployment.should respond_to(:end_time)
    end
    
    it 'should allow setting and retrieving the end time' do
      @deployment.end_time = time = 1.day.from_now
      @deployment.end_time.should == time
    end
    
    it 'should have a deactivated flag' do
      @deployment.should respond_to(:is_deactivated)
    end
    
    it 'should allow setting and retrieving the deactivated flag' do
      @deployment.is_deactivated = true
      @deployment.is_deactivated.should be_true
    end
  end
  
  describe 'validations' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should not be valid without a deployable' do
      @deployment.deployable = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:deployable)
    end

    it 'should be valid with a deployable' do
      @deployment.deployable = Deployable.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:deployable)
    end
    
    it 'should not be valid without a host' do
      @deployment.host = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:host)
    end

    it 'should be valid with a host' do
      @deployment.host = Host.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:host)
    end
    
    it 'should not be valid without a reason' do
      @deployment.reason = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:reason)
    end

    it 'should not be valid without a non-blank reason' do
      @deployment.reason = ''
      @deployment.valid?
      @deployment.errors.should be_invalid(:reason)
    end
    
    it 'should be valid with a reason' do
      @deployment.reason = 'test deployment'
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:reason)
    end
    
    it 'should not allow start time to be nil' do
      @deployment.start_time = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:start_time)
    end
    
    it 'should not allow start time to be in the past' do
      @deployment.start_time = 2.minutes.ago
      @deployment.valid?
      @deployment.errors.should be_invalid(:start_time)
    end
    
    it 'should not allow end time to be in the past' do
      @deployment.end_time = 2.minutes.ago
      @deployment.valid?
      @deployment.errors.should be_invalid(:end_time)      
    end
    
    it 'should not allow end time to be before start time' do
      @deployment.end_time = 10.minutes.from_now
      @deployment.start_time = 15.minutes.from_now
      @deployment.valid?
      @deployment.errors.should be_invalid(:end_time)            
    end
    
    it 'should be valid with a start time in the future' do
      @deployment.start_time = 5.minutes.from_now
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:start_time)            
    end
  
    it 'should be valid with a nil end time' do
      @deployment.end_time = nil
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:end_time)            
    end
    
    it 'should be valid with an end time in the future and later than the start time' do
      @deployment.start_time = 10.minutes.from_now
      @deployment.end_time = nil
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:end_time)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should have deployed services' do
      @deployment.should respond_to(:deployed_services)
    end
    
    it 'should allow setting and retrieving deployed services' do
      @deployment.deployed_services << deployed_services = Array.new(2) { DeployedService.generate! }
      @deployment.deployed_services.sort_by(&:id).should == deployed_services.sort_by(&:id)
    end
    
    it 'should belong to a deployable' do
      @deployment.should respond_to(:deployable)      
    end
    
    it 'should allow assigning the deployable' do
      @deployable = Deployable.generate!
      @deployment.deployable = @deployable
      @deployment.deployable.should == @deployable
    end

    it 'should have hosts' do
      @deployment.should respond_to(:hosts)
    end

    it 'should return the hosts from deployed services' do
      @deployment.deployed_services << deployed_services = Array.new(2) { DeployedService.generate! }
      @deployment.hosts.sort_by(&:id).should == deployed_services.collect(&:host).flatten.sort_by(&:id)
    end

    it 'should have an instance' do
      @deployment.should respond_to(:instance)
    end

    it "should return the deployment's instance" do
      @deployment.deployable = Deployable.generate!
      @deployment.instance.should == @deployment.deployable.instance
    end
    
    it 'should have an app' do
      @deployment.should respond_to(:app)
    end
    
    it "should return the deployable's app" do
      @deployment = Deployment.generate!
      @deployment.app.should == @deployment.deployable.app
    end
    
    it 'should have a customer' do
      @deployment.should respond_to(:customer)
    end
    
    it "should return the deployable's customer" do
      @deployment = Deployment.generate!
      @deployment.customer.should == @deployment.deployable.customer
    end
    
    it 'should have services' do
      @deployment.should respond_to(:services)
    end
    
    it "should return the deployable's services" do
      @deployment = Deployment.generate!
      @deployment.services.should == @deployment.deployable.services
    end
  end
  
  describe 'as a class' do
    it 'should be able to deploy from a deployable' do
      Deployment.should respond_to(:deploy_from_deployable)
    end
    
    describe 'when deploying from a deployable' do
      before :each do
        @deployable = Deployable.generate!
        @parameters = HashWithIndifferentAccess.new(DeployedService.generate!.attributes.merge(:reason => 'Because.', :start_time => Time.now))
      end
      
      it 'should allow a deployable and deployment parameters' do
        lambda { Deployment.deploy_from_deployable(@deployable, @parameters)}.should_not raise_error(ArgumentError)
      end
      
      it 'should require a deployable and deployment parameters' do
        lambda { Deployment.deploy_from_deployable(@deployable)}.should raise_error(ArgumentError)
      end
      
      it 'should fail if there is no reason specified in the deployment parameters' do
        @parameters[:reason] = nil
        lambda { Deployment.deploy_from_deployable(@deployable, @parameters)}.should raise_error
      end
      
      it 'should fail if there is no start time specified in the deployment parameters' do
        @parameters[:start_time] = nil
        lambda { Deployment.deploy_from_deployable(@deployable, @parameters)}.should raise_error
      end
      
      it 'should create a new deployment' do
        lambda { Deployment.deploy_from_deployable(@deployable, @parameters) }.should change(Deployment, :count)
      end
      
      it 'should set the new deployment reason to the reason from the parameters' do
        Deployment.delete_all
        Deployment.deploy_from_deployable(@deployable, @parameters)
        Deployment.first.start_time.to_i.should == @parameters[:start_time].to_i
      end
      
      it 'should set the new deployment start time to the start time from the parameters' do
        Deployment.delete_all
        Deployment.deploy_from_deployable(@deployable, @parameters)
        Deployment.first.reason.should == @parameters[:reason]        
      end
      
      it 'should set the new deployment end time to the end time from the parameters when it is available' do
        Deployment.delete_all
        time = 4.days.from_now
        Deployment.deploy_from_deployable(@deployable, @parameters.merge(:end_time => time))
        Deployment.first.end_time.to_i.should == time.to_i
      end
      
      it 'should deploy the new deployment with the deployment parameters, except for reason, start time, and end time' do
        deployment = {}
        Deployment.stubs(:create!).returns(deployment)
        @parameters[:end_time] = 4.days.from_now
        base_params = @parameters.clone
        base_params.delete(:start_time)
        base_params.delete(:reason)
        base_params.delete(:end_time)
        deployment.expects(:deploy).with(base_params)
        Deployment.deploy_from_deployable(@deployable, @parameters)
      end
      
      it 'should return the result of deploying the new deployment' do
        deployment = {}
        Deployment.stubs(:create!).returns(deployment)
        deployment.stubs(:deploy).returns('deployed')
        Deployment.deploy_from_deployable(@deployable, @parameters).should == 'deployed'     
      end
    end
    
    describe "when saving and deployed to a host which already has an active deployment of our deployable's instance" do
      before :each do
        @host = Host.generate!
        @deployable = Deployable.generate!
      end

      it 'should set the end time of a conflicting earlier deployment if it has no end time' do
        earlier_open       = Deployment.generate!(:host => @host, :start_time => Time.now, :end_time => nil, :deployable => @deployable)
        Deployment.generate!(:host => @host, :deployable => @deployable, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
        Deployment.find(earlier_open.id).end_time.to_i.should be_close(1.day.from_now.to_i, 2)
      end
      
      it 'should shorten the end time of a conflicting earlier deployment if is has an end time' do
        earlier_closed    = Deployment.generate!(:host => @host, :start_time => Time.now, :end_time => 2.days.from_now, :deployable => @deployable)
        Deployment.generate!(:host => @host, :deployable => @deployable, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
        earlier_closed.reload.end_time.to_i.should be_close(1.day.from_now.to_i, 2)
      end
      
      it 'should adjust the start time of a later conflicting deployment if our end time is set' do
        later_closed      = Deployment.generate!(:host => @host, :start_time => 2.days.from_now, :end_time => nil, :deployable => @deployable)        
        Deployment.generate!(:host => @host, :deployable => @deployable, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
        later_closed.reload.start_time.to_i.should be_close(3.days.from_now.to_i, 2)
      end
      
      it 'should set our end time to the start time of a later conflicting deployment if our end time is not set' do
        Deployment.generate!(:host => @host, :start_time => 2.days.from_now, :end_time => 5.days.from_now, :deployable => @deployable)        
        deployment = Deployment.generate!(:host => @host, :deployable => @deployable, :start_time => 1.day.from_now, :end_time => nil)
        deployment.reload.end_time.to_i.should be_close(2.days.from_now.to_i, 2)
      end
      
      it 'should deactivate contained conflicting later deployments' do
        later_contained   = Deployment.generate!(:host => @host, :start_time => 2.days.from_now, :end_time => 4.days.from_now, :deployable => @deployable)
        deployment = Deployment.generate!(:host => @host, :deployable => @deployable, :start_time => 2.days.from_now, :end_time => 5.days.from_now)
        later_contained.reload.should_not be_active
      end
    end
    
    it 'should be able to find active deployments' do
      Deployment.should respond_to(:active)
    end
    
    describe 'when finding active deployments' do
      before :each do
        Deployment.any_instance.stubs(:adjust_conflicting_deployments).returns(true)  # otherwise it is very difficult to create this deployment data
        @past = Deployment.generate!
        @past.update_attribute(:start_time,  2.days.ago)
        @past.update_attribute(:end_time, 1.day.ago)
        
        @current_closed = Deployment.generate!(:start_time => Time.now, :end_time => 1.day.from_now)
        @current_closed.update_attribute(:start_time, 2.days.ago)

        @current_open = Deployment.generate!(:start_time => Time.now, :end_time => nil)
        @current_open.update_attribute(:start_time, 2.days.ago)

        @future = Deployment.generate!(:start_time => 1.day.from_now, :end_time => 2.days.from_now)
      end
      
      it 'should work without arguments' do
        lambda { Deployment.active }.should_not raise_error(ArgumentError)
      end
      
      it 'should not complain about arguments' do
        # this is a side-effect of this being a named scope, evidently
        lambda { Deployment.active(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should return the empty list if there are no deployments' do
        Deployment.delete_all
        Deployment.active.should == []
      end
      
      it 'should not include past deployments in the returned list' do
        Deployment.active.should_not include(@past)
      end
      
      it 'should not include future deployments in the returned list' do
        Deployment.active.should_not include(@future)
      end
      
      it 'should include deployments with start times in the past and end times in the future' do
        Deployment.active.should include(@current_closed)
      end
      
      it 'should include deployments with start times in the past and nil end times' do
        Deployment.active.should include(@current_open)
      end
      
      it 'should not include deployments which have been deactivated' do
        @current_open.deactivate
        Deployment.active.should_not include(@current_open)
      end
    end
  end
  
  it 'should be able to be deactivated' do
    Deployment.new.should respond_to(:deactivate)
  end
  
  describe 'deactivating' do
    before :each do
      @deployment = Deployment.generate!
    end
    
    it 'should work without arguments' do
      lambda { @deployment.deactivate }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @deployment.deactivate(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should set the deactivated flag' do
      @deployment.deactivate
      @deployment.is_deactivated.should be_true
    end
  end
  
  it 'should be able to deploy' do
    Deployment.new.should respond_to(:deploy)
  end
  
  describe 'when deploying' do
    before :each do
      @services = Array.new(2) { Service.generate! }
      dependencies = Array.new(2) { Service.generate! }
      @services.first.depends_on << dependencies
      @deployment = Deployment.generate!
      @deployment.instance.services << @services
      @services += dependencies
      @parameters = DeployedService.generate!.attributes
      @parameters.delete("id")
    end
      
    it 'should accept deployment parameters' do
      lambda { @deployment.deploy(@parameters) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require deployment parameters' do
      lambda { @deployment.deploy }.should raise_error(ArgumentError)
    end
    
    describe 'and the deployment already has deployed services' do
      before :each do
        @deployment.deployed_services.generate!
      end
      
      it 'should not change the deployed services' do
        deployed_services = @deployment.deployed_services
        @deployment.deploy(@parameters)
        @deployment.deployed_services.should == deployed_services
      end
      
      it 'should return false' do
        @deployment.deploy(@parameters).should be_false        
      end
    end
    
    it 'should create deployed services for all the services required by our deployable' do
      @deployment.deploy(@parameters)
      @deployment.deployed_services.size.should == @services.size
    end
    
    it 'should use the service names from our deployable when creating the deployed services' do
      @deployment.deploy(@parameters)
      @deployment.deployed_services.collect(&:service_name).sort.should == @services.collect(&:name).sort      
    end
    
    it 'should use the parameter settings for the named service from our deployable when creating the deployed services' do
      @services.each do |service|
        @deployment.deployable.stubs(:service_parameters).with(service.name).returns({ "foo" => "service #{service.name}" })
      end
      @deployment.deploy(@parameters)
      @services.each do |service|
        deployed_service = @deployment.deployed_services.detect {|ds| ds.service_name == service.name }
        deployed_service.parameters.should == @deployment.deployable.service_parameters(service.name)
      end
    end
    
    it 'should use the deployment parameters when creating the deployed services' do
      @deployment.deploy(@parameters)
      @deployment.deployed_services.each do |deployed_service|
        deployed_service.host_id.should == @parameters["host_id"]  # this is all we're really worried about at the moment and it should work as a reasonable proxy for the assignment in the future
      end
    end
    
    it 'should fail when required deployment parameters are missing' do
      @parameters.delete("host_id")
      lambda { @deployment.deploy(@parameters) }.should raise_error
    end
    
    it 'should return true when successul' do
      @deployment.deploy(@parameters).should be_true
    end
  end

  it 'should be able to undeploy' do
    Deployment.new.should respond_to(:undeploy)
  end
  
  describe 'when undeploying' do
    before :each do
      @deployment = Deployment.generate!
    end
    
    it 'should work without arguments' do
      lambda { @deployment.undeploy }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @deployment.undeploy(:foo) }.should raise_error(ArgumentError)
    end
    
    describe 'and this deployment is a new record' do
      before :each do
        @deployment = Deployment.spawn(:start_time => 5.seconds.ago, :end_time => nil)
      end
      
      it 'should not modify the end time' do
        @deployment.undeploy
        @deployment.end_time.should be_nil
      end
      
      it 'should return false' do
        @deployment.undeploy.should be_false
      end
    end
    
    describe 'and this deployment is not currently active' do
      before :each do
        @end = 1.hour.ago
        @deployment.update_attribute(:start_time, 1.day.ago)
        @deployment.update_attribute(:end_time, @end)
      end
      
      it 'should not modify the end time' do
        @deployment.undeploy
        @deployment.end_time.should == @end
      end
      
      it 'should return false' do
        @deployment.undeploy.should be_false
      end
    end
    
    describe 'and the deployment is currently active' do
      before :each do
        @deployment.update_attribute(:start_time, 1.day.ago)
        @t = Time.now
        Time.stubs(:now).returns(@t)
      end
      
      it 'should set the end time on the deployment to the current time' do
        @deployment.undeploy
        @deployment.end_time.to_i.should == @t.to_i
      end
      
      it 'should return the set end time' do
        @deployment.undeploy.to_i.should == @t.to_i
      end
    end
  end

  it 'should be able to determine if it is currently active' do
    Deployment.new.should respond_to(:active?)
  end
  
  describe 'when determining if it is currently active' do
    before :each do
      @deployment = Deployment.generate!
    end
    
    it 'should work without arguments' do
      lambda { @deployment.active? }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @deployment.active?(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should not be active if the start time is not set' do
      @deployment.start_time = nil
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is in the future' do
      @deployment.start_time = 1.day.from_now
      @deployment.should_not be_active
    end
    
    it 'should not be active if the end time is in the past' do
      @deployment.end_time = 1.day.ago
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is in the past and the end time is now' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = 1.day.ago
      @deployment.end_time = t
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is now and the end time is now' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = t
      @deployment.should_not be_active      
    end
    
    it 'should be active if the start time is in the past and the end time is in the future' do
      @deployment.start_time = 1.day.ago
      @deployment.end_time = 1.day.from_now
      @deployment.should be_active      
    end
    
    it 'should be active if the start time is in the past and the end time is nil' do
      @deployment.start_time = 1.day.ago
      @deployment.end_time = nil
      @deployment.should be_active            
    end
    
    it 'should be active if the start time is now and the end time is in the future' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = 1.day.from_now
      @deployment.should be_active                  
    end
    
    it 'should be active if the start time is now and the end time is nil' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = nil
      @deployment.should be_active                        
    end
    
    it 'should not be active if it has been deactivated' do
      @deployment.start_time = Time.now
      @deployment.end_time = nil
      @deployment.deactivate
      @deployment.should_not be_active
    end
  end
  
  it 'should be able to determine which deployments share our instance, are current, and deployed to our host' do
    Deployment.new.should respond_to(:find_conflicting_deployments)
  end
  
  describe 'when finding conflicting deployments' do
    before :each do
      @host = Host.generate!
      @deployment = Deployment.generate!(:host => @host)
    end
    
    it 'should work without arguments' do
      lambda { @deployment.find_conflicting_deployments }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @deployment.find_conflicting_deployments(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return the empty list if our host is not set' do
      @deployment.host = nil
      @deployment.find_conflicting_deployments.should == []      
    end
    
    it 'should return the empty list if our deployable is not set' do
      @deployment.deployable = nil
      @deployment.find_conflicting_deployments.should == []
    end
    
    it 'should return the empty list if our instance is not set' do
      @deployment.deployable.instance = nil
      @deployment.find_conflicting_deployments.should == []      
    end
    
    it 'should not match deployments which do not share our instance' do
      other_deployment = Deployment.generate!
      @deployment.find_conflicting_deployments.should_not include(other_deployment)
    end
    
    it 'should not match deployments which share our instance but are not deployed to the same host' do
      other_deployable = Deployable.generate!(:instance => @deployment.instance)
      other_deployment = Deployment.generate!(:deployable => other_deployable)
      @deployment.find_conflicting_deployments.should_not include(other_deployment)
    end
    
    it 'should not match deployments of the same instance to our host which end before our start time' do
      deployment = Deployment.generate!(:host => @host, :start_time => 1.day.from_now, :end_time => 2.days.from_now)
      other_deployment = Deployment.new(:host => @host, :deployable => deployment.deployable, :start_time => 3.days.from_now, :end_time => 4.days.from_now)
      other_deployment.find_conflicting_deployments.should_not include(deployment)      
    end
    
    it 'should not match deployments of the same instance to the same host which start after our end time' do
      deployment = Deployment.generate!(:host => @host, :start_time => 4.days.from_now, :end_time => 5.days.from_now)
      other_deployment = Deployment.new(:host => @host, :deployable => deployment.deployable, :start_time => 2.days.from_now, :end_time => 3.days.from_now)
      other_deployment.find_conflicting_deployments.should_not include(deployment)      
    end
    
    it 'should match deployments which share our instance and host, and include our start time' do
      Deployment.delete_all
      deployment = Deployment.generate!(:host => @host, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
      other_deployment = Deployment.new(:host => @host, :deployable => deployment.deployable, :start_time => 2.days.from_now, :end_time => 4.days.from_now)
      ###
      other_deployment.find_conflicting_deployments.should include(deployment)      
    end

    it 'should match deployments which share our instance and host, and include our end time' do 
      deployment = Deployment.generate!(:host => @host, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
      other_deployment = Deployment.new(:host => @host, :deployable => deployment.deployable, :start_time => Time.now, :end_time => 2.days.from_now)
      other_deployment.find_conflicting_deployments.should include(deployment)      
    end
    
    it 'should not match deployments which have been deactivated' do
      Deployment.delete_all
      deployment = Deployment.generate!(:host => @host, :start_time => 1.day.from_now, :end_time => 3.days.from_now)
      deployment.deactivate
      deployment.reload
      other_deployment = Deployment.new(:host => @host, :deployable => deployment.deployable, :start_time => Time.now, :end_time => 2.days.from_now)
      other_deployment.find_conflicting_deployments.should_not include(deployment)            
    end
  end
end
