require File.dirname(__FILE__) + '/../spec_helper'
require 'growl_controller'
require 'ext/growl'
require 'spec_object'

describe GrowlController do
  before(:each) do
    @mock_growl = mock('Growl')
    
    @controller = GrowlController.alloc.init
    @controller.growl = @mock_growl
  end
  
  it 'should growl a processed spec' do
    spec = SpecObject.new    
    mock_notification = mock('Notification')    
    mock_notification.stub!(:userInfo).and_return([spec])
    @controller.growl.should_receive(:notify)
    @controller.specRunFinishedSingleSpec(mock_notification)
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