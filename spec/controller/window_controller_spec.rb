require File.dirname(__FILE__) + '/../spec_helper'
require 'window_controller'
require 'growl_controller'
require 'ext/growl'
require 'spec_runner'
require 'spec_list'

describe WindowController do
  before(:each) do
    @mock_runButton = mock('runButton', :title => 'Run')
    @mock_runButton.stub!(:enabled=)
    
    @mock_pathTextField = mock('pathTextField', :stringValue => File.dirname(__FILE__))
    @mock_pathTextField.stub!(:hidden=)
    @mock_pathTextField.stub!(:stringValue=)
    
    @mock_statusBar = mock('statusBar')
    @mock_statusBar.stub!(:hidden=)
    @mock_statusBar.stub!(:minValue=)
    @mock_statusBar.stub!(:doubleValue=)
    @mock_statusBar.stub!(:indeterminate=)
    @mock_statusBar.stub!(:startAnimation)
    @mock_statusBar.stub!(:incrementBy)    
    
    @mock_statusLabel = mock('statusLabel')
    @mock_statusLabel.stub!(:hidden=)
    @mock_statusLabel.stub!(:stringValue=)
    
    @mock_window = mock('Window')
    @mock_window.stub!(:frameUsingName=)
    @mock_window.stub!(:frameAutosaveName=)
    
    @controller = WindowController.new
    @controller.runButton = @mock_runButton
    @controller.pathTextField = @mock_pathTextField
    @controller.statusBar = @mock_statusBar
    @controller.statusLabel = @mock_statusLabel
    @controller.stub!(:window).and_return(@mock_window)
    
    $app = mock('App')
    $app.stub!(:default_for_key)
    $spec_list = SpecList.new
    SpecRunner.stub!(:run_in_path).and_return(File.dirname(__FILE__))    
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should not allow to run specs if path textfield is empty' do
    File.should_not_receive(:exist?)
    @mock_pathTextField.stub!(:stringValue).and_return('')
    @controller.runSpecs(nil).should be_false
  end
  
  it 'should not allow to run specs if path textfield contains an invalid path' do
    File.should_receive(:exist?).with('invalid')
    @mock_pathTextField.stub!(:stringValue).and_return('invalid')
    @controller.runSpecs(nil).should be_false
  end
  
  it 'should run specs with in a valid path' do
    @mock_pathTextField.stub!(:stringValue).and_return(File.dirname(__FILE__))
    @controller.runSpecs(nil)
  end
  
  it 'should show the status panel (and hide the input)' do
    @mock_runButton.should_receive(:enabled=).with(false)
    @mock_pathTextField.should_receive(:hidden=).with(true)
    @mock_statusBar.should_receive(:hidden=).with(false)
    @mock_statusLabel.should_receive(:hidden=).with(false)
    @controller.showStatusPanel
  end
  
  it 'should show the input panel (and hide the status)' do
    @mock_runButton.should_receive(:enabled=).with(true)
    @mock_pathTextField.should_receive(:hidden=).with(false)
    @mock_statusBar.should_receive(:hidden=).with(true)
    @mock_statusLabel.should_receive(:hidden=).with(true)
    @controller.showInputPanel    
  end
  
  it 'should init the status label with a cooool text on spec_run_start' do
    @mock_statusLabel.should_receive(:stringValue=)
    @controller.runSpecs(nil)    
  end
  
  it 'should hide the status panel on finished spec run' do
    @controller.should_receive(:showInputPanel)
    @controller.specRunFinished(nil)
  end
  
  it 'should set status bar to indeterminate and start its animation on spec run' do
    @mock_statusBar.should_receive(:indeterminate=).with(true)
    @mock_statusBar.should_receive(:startAnimation)
    @controller.runSpecs(nil)
  end
  
  it 'should display progress info in statusLabel for passed, pending and failed specs' do
    @mock_statusLabel.should_receive(:stringValue=)
    @controller.specRunFinishedSingleSpec(nil)    
  end
  
  it 'should init the determinated status bar on spec_run_start' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:userInfo).and_return([15])
    @mock_statusBar.should_receive(:indeterminate=).with(false)
    @mock_statusBar.should_receive(:maxValue=).with(15)
    @controller.specRunStarted(mock_notification)
  end
  
  it 'should update the statusbar on spec run' do
    @mock_statusBar.should_receive(:incrementBy).with(1.0)
    @controller.specRunFinishedSingleSpec(nil)        
  end 
  
  it 'should receive changeText notifications from path text field and save its current value to defaults' do
    mock_notification = mock('Notification')
    mock_notification.stub!(:object).and_return(@mock_pathTextField)
    $app.should_receive(:default_for_key).with(:spec_run_path, File.dirname(__FILE__))
    @controller.controlTextDidChange(mock_notification)
  end
  
  it 'should restore the last run path on awake' do
    $app.should_receive(:default_from_key).with(:spec_run_path).and_return('test')
    @mock_pathTextField.should_receive(:stringValue=).with('test')
    @controller.awakeFromNib
  end
  
  it 'should init windowstate autosave on wake up' do
    $app.stub!(:default_from_key)
    @controller.should_receive(:initAndSetAutomaticPositionAndSizeStoring)
    @controller.awakeFromNib
  end
  
  it 'should setup the windowstate from defaults' do
    @mock_window.should_receive(:frameUsingName=)
    @mock_window.should_receive(:frameAutosaveName=)
    @controller.initAndSetAutomaticPositionAndSizeStoring
  end
  
  it 'should show window again after resurrection' do
    @mock_window.should_receive(:makeKeyAndOrderFront)
    @controller.resurrectWindow(nil)
  end
end