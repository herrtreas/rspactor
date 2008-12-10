require File.dirname(__FILE__) + '/../spec_helper'
require 'growl_controller'
require 'ext/growl'
require 'options'
require 'spec_object'
require 'spec_runner'

describe GrowlController do
  before(:each) do
    $app = mock('App', :processed_spec_count => 10)
    @mock_job = mock('Job')
    @mock_job.stub!(:hide_growl_messages_for_failed_examples).and_return(false)
    @mock_growl = mock('Growl')    
    @controller = GrowlController.alloc.init
    @controller.growl = @mock_growl
    SpecRunner.stub!(:current_job).and_return(@mock_job)
  end
  
  it 'should growl a processed example' do
    Options.stub!(:summarize_growl_output?).and_return(false)
    spec = SpecObject.new    
    mock_notification = mock('Notification')    
    mock_notification.stub!(:userInfo).and_return([spec])
    @controller.growl.should_receive(:notify)
    @controller.specRunFinishedSingleSpec(mock_notification)
  end
  
  it 'should not growl a processed example if summarization is activated (prefs)' do
    Options.stub!(:summarize_growl_output?).and_return(true)
    @controller.growl.should_not_receive(:notify)
    @controller.specRunFinishedSingleSpec(nil)
  end
  
  it 'should growl after all specs have been run' do
    mock_notification = mock('Notification')    
    mock_notification.stub!(:userInfo).and_return([10.23, 10, 5, 1])
    @controller.growl.should_receive(:notify)    
    @controller.specRunFinishedWithSummaryDump(mock_notification)
  end
  
  it 'should receive errors and growl them' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return(['Error'])    
    @controller.growl.should_receive(:notify)
    @controller.errorPosted(mock_notification)
  end
end