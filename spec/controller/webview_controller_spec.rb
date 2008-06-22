require File.dirname(__FILE__) + '/../spec_helper'
require 'webview_controller'
require 'html_view'
require 'spec_file_view'

describe WebviewController do
  before(:each) do
    @mock_view = mock('View')
    @mock_view.stub!(:mainFrameURL=)
    @mock_view.stub!(:shouldCloseWithWindow=)
    @mock_view.stub!(:frameLoadDelegate=)
    @controller = WebviewController.new    
    @controller.view = @mock_view
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should load the "welcome" page on awake' do
    @controller.should_receive(:loadHtml).with('welcome.html')
    @controller.awakeFromNib
  end
  
  it 'should set webview to garbagecollect itself when window is closed' do
    @mock_view.should_receive(:shouldCloseWithWindow=).with(true)
    @controller.awakeFromNib    
  end
  
  it 'should load a html file into its view' do
    @mock_view.should_receive(:mainFrameURL=).with(/welcome.html/)    
    @controller.loadHtml('welcome.html')
  end
  
  it 'should load the spec_file view' do
    mock_notification = mock('Notification')
    mock_table = mock('Table')
    mock_table.stub!(:selectedRow).and_return(1)
    mock_notification.stub!(:object).and_return(mock_table)
    @controller.should_receive(:loadHtml).with('spec_file.html')
    @controller.showSpecFileView(mock_notification)
  end
end