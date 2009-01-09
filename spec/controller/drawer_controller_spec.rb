require File.dirname(__FILE__) + '/../spec_helper'
require 'drawer_controller'
require 'example_files'
require 'example_matcher'
require 'defaults'

describe DrawerController do
  before(:each) do
    $app = mock('App')
    $app.stub!(:post_notification)
    $app.stub!(:default_for_key)
    $app.stub!(:default_from_key)
    
    @mock_window = mock('Window')
    @mock_hide_box = mock('HideBox', :state => 1)
    @mock_hide_box.stub!(:state=)
    @mock_drawer = mock('Drawer')
    @mock_drawer.stub!(:openOnEdge)
    @controller = DrawerController.new
    @controller.drawer = @mock_drawer
    @controller.hideBox = @mock_hide_box
    @controller.stub!(:window).and_return(@mock_window)
    ExampleFiles.init
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should open the drawer on startup' do
    @controller.stub!(:restoreSizeFromLastSession)
    @mock_drawer.should_receive(:openOnEdge).with(0)
    @controller.awakeFromNib
  end
  
  it 'should set the hideBox state on startup by defaults' do
    Defaults.should_receive(:get).and_return(1)    
    @controller.stub!(:restoreSizeFromLastSession)    
    @mock_hide_box.should_receive(:state=).with(1)
    @controller.awakeFromNib
  end
  
  it 'should focus the table on demand' do
    mock_notification = mock('Notification')
    @mock_window.should_receive(:makeFirstResponder)
    @controller.setFocusOnTable(mock_notification)
  end
  
  it 'should set the spec_list filter on change of hideButton' do
    ExampleFiles.should_receive(:filter=).with(:failed)
    mock_sender = mock('Sender', :state => 1)
    @controller.hideBoxClicked(mock_sender)    
    ExampleFiles.should_receive(:filter=).with(:all)
    mock_sender = mock('Sender', :state => 0)
    @controller.hideBoxClicked(mock_sender)    
  end
  
  it 'should post a "spec_file_table_reload_required" notification on hideButtonClick' do
    $app.should_receive(:post_notification).with(:file_table_reload_required)
    mock_sender = mock('Sender', :state => 1)
    @controller.hideBoxClicked(mock_sender)
  end
  
  it 'should restore its last size on wakeup' do
    @controller.should_receive(:restoreSizeFromLastSession)
    @controller.awakeFromNib
  end
  
  it 'should use defaults or store the current size on restoreSize' do
    Defaults.should_receive(:get).with(:files_drawer_width).and_return('10')
    @mock_drawer.should_receive(:setContentSize)
    @controller.restoreSizeFromLastSession
  end
end