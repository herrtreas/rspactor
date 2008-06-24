require File.dirname(__FILE__) + '/../spec_helper'
require 'drawer_controller'

describe DrawerController do
  before(:each) do
    @mock_window = mock('Window')
    @controller = DrawerController.new
    @controller.stub!(:window).and_return(@mock_window)
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should open the drawer on startup' do
    mock_drawer = mock('Drawer')
    mock_drawer.should_receive(:openOnEdge).with(0)
    @controller.drawer = mock_drawer
    @controller.awakeFromNib
  end
  
  it 'should focus the table on demand' do
    mock_notification = mock('Notification')
    @mock_window.should_receive(:makeFirstResponder)
    @controller.setFocusOnTable(mock_notification)
  end
end