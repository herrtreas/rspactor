require File.dirname(__FILE__) + '/../spec_helper'
require 'drawer_controller'

describe DrawerController do
  before(:each) do
    @controller = DrawerController.new
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
end