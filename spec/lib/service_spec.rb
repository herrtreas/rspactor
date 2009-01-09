require File.dirname(__FILE__) + '/../spec_helper'
require 'service'
require 'notification'

describe Service do
  it 'should init its drb server on startup' do
    DRb.should_receive(:start_service)
    Service.init
  end
  
  it 'should answer on ping using the drb server connection' do
    Service.init('28126')
    @client = DRbObject.new(nil, "druby://127.0.0.1:28126")    
    @client.ping.should be_kind_of(Time)
  end
  
  it 'should accept incoming message calls' do
    Service.incoming(:test, 1,1,1)
  end
  
  it 'should post notifications for incoming message calls' do    
    Notification.should_receive(:send).with(:buddy_is_rockin, true, 'hell')
    Service.incoming(:buddy_is_rockin, true, 'hell')    
  end
end