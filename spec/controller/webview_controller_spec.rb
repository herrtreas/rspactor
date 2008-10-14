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
    @mock_view.stub!(:isLoading)
    @mock_tab_bar = mock('TabBar')
    @mock_tab_bar.stub!(:setWidth_forSegment)
    @controller = WebviewController.new    
    @controller.view = @mock_view
    @controller.tabBar = @mock_tab_bar
    @controller.stub!(:activateHtmlView)
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should setup the tabbar and activate the "dashboard" page on awake' do
    @controller.should_receive(:setupTabBar).with(:dashboard)
    @controller.awakeFromNib
  end
  
  it 'should set webview to garbagecollect itself when window is closed' do
    @mock_view.should_receive(:shouldCloseWithWindow=).with(true)
    @controller.awakeFromNib    
  end
  
  it 'should load a html file into its view' do
    @mock_view.should_receive(:mainFrameURL=).with(/dashboard.html/)    
    @controller.loadHtml('dashboard.html')
  end
  
  it 'should load the spec_file view' do
    @controller.stub!(:labelForView)
    mock_table = mock('Table')
    mock_table.stub!(:selectedRow).and_return(1)
    @controller.should_receive(:activateHtmlView).with(:spec_view)
    @controller.showSpecFileView(1)
  end

  it 'should know if editor integration is enabled' do
    $app.should_receive(:default_from_key).with(:editor_integration).and_return('1')    
    @controller.editor_integration_enabled?.should be_true
  end

  it 'should know if editor integration is disabled' do
    $app.should_receive(:default_from_key).with(:editor_integration).and_return('0')    
    @controller.editor_integration_enabled?.should be_false
  end

  it 'should not try to run an editor if integration is disabled' do
    @controller.stub!(:editor_integration_enabled?).and_return(false)
    $app.should_not_receive(:default_from_key)
    @controller.webView_runJavaScriptAlertPanelWithMessage(nil, 'test.rb:5')
  end

  it "should open Netbeans if the nb bin path is set" do
    @controller.stub!(:editor_integration_enabled?).and_return(true)
    $app.stub!(:default_from_key).and_return 'Netbeans'
    Netbeans.should_receive(:open_file_with_line)
    @controller.webView_runJavaScriptAlertPanelWithMessage(nil, 'test.rb:5')
  end
  
  it 'should open TextMate on JS alert only if the nb bin path is not set' do
    @controller.stub!(:editor_integration_enabled?).and_return(true)
    $app.stub!(:default_from_key).and_return 'TextMate'
    TextMate.should_receive(:open_file_with_line)
    @controller.webView_runJavaScriptAlertPanelWithMessage(nil, 'test.rb:5')
  end

  it 'should setup the tabbar and load the corresponding view' do
    @mock_tab_bar.should_receive(:setWidth_forSegment).exactly(3).times
    @controller.should_receive(:activateHtmlView).with(:dashboard)
    @controller.setupTabBar(:dashboard)
  end

  it 'should load the corresponding html view on tabbar click' do
    @mock_tab_bar.stub!(:selectedSegment).and_return(0)
    @controller.should_receive(:loadHtmlView)
    @controller.tabBarClicked(nil)
  end

  it 'should show the current spec filew in the view if current clicked tab is the :spec_view' do
    @mock_tab_bar.should_receive(:selectedSegment).and_return(2)
    @controller.should_receive(:showSpecFileView)
    @controller.tabBarClicked(nil)    
  end
  
  it 'should allow setting the tabbar label for a view (including enabling)' do
    @mock_tab_bar.should_receive(:setEnabled_forSegment).with(true, 2)
    @mock_tab_bar.should_receive(:setLabel_forSegment).with('Test', 2)
    @controller.labelForView(:spec_view, 'Test')
  end
  
  it 'should return the tabbar index for a view' do
    @controller.indexForView(:dashboard).should eql(0)
    @controller.indexForView(:output).should eql(1)
    @controller.indexForView(:spec_view).should eql(2)
  end
  
end