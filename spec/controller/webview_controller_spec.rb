require File.dirname(__FILE__) + '/../spec_helper'
require 'webview_controller'
require 'html_view'
require 'spec_file_view'
require 'textmate'
require 'netbeans'

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
    mock_table = mock('Table')
    mock_table.stub!(:selectedRow).and_return(1)
    @controller.should_receive(:loadHtml).with('spec_file.html')
    @controller.showSpecFileView(1)
  end

  it "should open Netbeans if the nb bin path is set" do
    $app.stub!(:default_from_key).and_return 'netbeans'
    Netbeans.should_receive(:open_file_with_line)
    @controller.webView_runJavaScriptAlertPanelWithMessage(nil, 'test.rb:5')
  end
  
  it 'should open TextMate on JS alert only if the nb bin path is not set' do
    $app.stub!(:default_from_key).and_return ''
    TextMate.should_receive(:open_file_with_line)
    @controller.webView_runJavaScriptAlertPanelWithMessage(nil, 'test.rb:5')
  end
end