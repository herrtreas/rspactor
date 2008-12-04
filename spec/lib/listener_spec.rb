require File.dirname(__FILE__) + '/../spec_helper'
require 'listener'

describe Listener do
  before(:each) do
    $app = mock('App')
    $app.stub!(:receive)
  end
  
  it 'should define a global callback to use with fsevents callbacks' do
    Listener.class_variables.should include('@@callback')
  end
  
  it 'should return if a listener was already defined' do
    Listener.stub!(:already_running?).and_return(true)
    Listener.init($fpath_simple).should be_false
  end
  
  it 'should know if another instance is already running' do
    lambda do
      Listener.init($fpath_simple)
      Listener.already_running?.should be_true
    end
  end
  
  describe 'with manually added listen_to requests' do    
    before(:each) do
      @spec = SpecObject.new(:full_file_path => 'test.rb')
      @spec2 = SpecObject.new(:full_file_path => 'test2.rb')
      @mock_notification = mock('Notification')
      @mock_notification.stub!(:userInfo).and_return(['/test.html.haml', @spec])      
      Listener.reset_observation_list
    end
    
    it 'should add the request to the observation list' do  
      Listener.add_request_to_observation_list(@mock_notification)
      Listener.observation_list.should have(1).record
    end

    it 'should add different requests to the observation list' do
      mock_second_notification = mock('Notification')
      mock_second_notification.stub!(:userInfo).and_return(['/test2.html.haml', @spec2])            
      Listener.add_request_to_observation_list(@mock_notification)
      Listener.add_request_to_observation_list(mock_second_notification)
      Listener.observation_list.should have(2).record      
    end

    it 'should not add the same request twice' do
      Listener.add_request_to_observation_list(@mock_notification)      
      Listener.observation_list.should have(1).record
      Listener.observation_list['/test.html.haml'].should have(1).record
    end

    it 'add a second request (same file) to the firsts spec list' do
      mock_second_notification = mock('Notification')
      mock_second_notification.stub!(:userInfo).and_return(['/test.html.haml', @spec2])            
      Listener.add_request_to_observation_list(@mock_notification)
      Listener.add_request_to_observation_list(mock_second_notification)      
      Listener.observation_list.should have(1).record
      Listener.observation_list['/test.html.haml'].should have(2).records
    end
    
    it 'should return the specs to run for a specific file' do
      Listener.add_request_to_observation_list(@mock_notification)
      Listener.file_covered_by_observation?('/test.html.haml').should be_true
    end
    
    it 'should return the specs for a file' do
      Listener.add_request_to_observation_list(@mock_notification)
      Listener.specs_for_observed_file('/test.html.haml').should have(1).record
    end
  end
end