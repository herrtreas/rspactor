require File.dirname(__FILE__) + '/../spec_helper'

require 'app_controller'
require 'service'
require 'spec_object'
require 'spec_runner'
require 'runner_queue'
require 'example_files'
require 'example_file'
require 'example_matcher'

describe AppController do
  before(:each) do
    @app = AppController.new
    @app.stub!(:setupActiveBadge)
    @app.example_start_time = 0.0
    @mock_spec = mock('SpecObject', :state => :failed, :full_file_path => '/tmp/test', :previous_state => :failed, :file_of_first_backtrace_line => 'test')    
    @mock_spec.stub!(:file_object=)
    @mock_spec.stub!(:full_file_path=)
    @mock_spec.stub!(:previous_state=)
    @mock_spec.stub!(:run_time=)
    @mock_spec.stub!(:backtrace).and_return(['/test.rb:5'])
  end
  
  it 'should init the global managers on "init"' do
    ExampleFiles.should_receive(:init)
    SpecRunner.should_receive(:init)
    AppController.new
  end
  
  it 'should start the drb service on "applicationDidFinishLaunching" notification' do
    Service.should_receive(:init)
    @app.applicationDidFinishLaunching(mock('Notificaion'))
  end
  
  it 'should set the total_spec_count for spec_list through "spec_run_start" notification' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([15])
    @app.spec_run_has_started(mock_notification)
    $total_spec_count.should eql(15)
  end
  
  it 'should clear spec run count on "spec_run_start"' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([15])
    @app.spec_run_has_started(mock_notification)
    $processed_spec_count.should eql(0)
  end

  it 'should taint all files on "spec_run_start"' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([15])
    ExampleFiles.should_receive(:tainting_required_on_all_files!)
    @app.spec_run_has_started(mock_notification)
  end
  
  it 'should track the processed spec run count' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([@mock_spec])
    @app.stub!(:post_notification)
    old_spec_count = $processed_spec_count
    @app.spec_run_processed(mock_notification)
    $processed_spec_count.should_not eql(old_spec_count)
  end
  
  it 'should add passed, pending or failed specs to the list' do
    spec_object = SpecObject.new(:backtrace => ['/test.rb:3'])
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([spec_object])
    ExampleFiles.should_receive(:add_spec).with(spec_object)
    @app.spec_run_processed(mock_notification)
  end
  
  it 'should create a global reference of itself' do
    $app.should be_kind_of(AppController)
  end
  
  it 'should allow to post any notification' do
    mock_center = mock('Center')
    mock_center.should_receive(:postNotificationName_object_userInfo)
    @app.stub!(:center).and_return(mock_center)
    @app.post_notification(:test, 'huhu')
  end
  
  it 'should have a reference to users defaults object' do
    @app.defaults.should eql(OSX::NSUserDefaults.standardUserDefaults)
  end
  
  it 'should read the defauls object' do
    @app.defaults.should_receive(:stringForKey).and_return('Test')
    @app.default_from_key(:test).should eql('Test')
  end
  
  it 'should return the rescue_value if defaults doesnt contain key' do
    @app.defaults.stub!(:stringForKey).and_return(nil)
    @app.default_from_key(:test, 'MU').should eql('MU')    
  end
  
  it 'should set a default value' do
    @app.defaults.should_receive(:setObject_forKey).with('FOOKuchen', 'test')
    @app.default_for_key(:test, 'FOOKuchen')
  end
  
  it 'should send a notification on the first failing spec' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([@mock_spec])
    @app.stub!(:post_notification)
    @app.should_receive(:post_notification).once.with(:first_failed_spec, @mock_spec)
    @app.spec_run_processed(mock_notification)
    @app.spec_run_processed(mock_notification)
  end
  
  it 'should send a notification about processed specs' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([@mock_spec])
    @app.stub!(:post_notification)
    @app.should_receive(:post_notification).once.with(:spec_run_processed, @mock_spec)
    @app.spec_run_processed(mock_notification)
  end
  
  it 'should post a notification if the application gets resurrected' do
    @app.should_receive(:post_notification).once.with(:application_resurrected)
    @app.applicationShouldHandleReopen_hasVisibleWindows(nil, nil)    
  end
end