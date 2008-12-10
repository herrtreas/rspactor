require File.dirname(__FILE__) + '/../spec_helper'
require 'window_controller'
require 'growl_controller'
require 'ext/growl'
require 'spec_runner'
require 'example_runner_job'

describe WindowController do
  before(:each) do
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
    @mock_statusLabel.stub!(:textColor=)
    
    @mock_window = mock('Window')
    @mock_window.stub!(:frameUsingName=)
    @mock_window.stub!(:frameAutosaveName=)    
    @mock_window.stub!(:makeFirstResponder)
    
    @mock_toolbar_item_run = mock('ToolbarItemRun')
    @mock_toolbar_item_run.stub!(:image=)
    @mock_toolbar_item_run.stub!(:label=)
    @mock_toolbar_item_run.stub!(:action=)
    @mock_toolbar_item_path = mock('ToolbarItemPath')
    @mock_toolbar_item_path.stub!(:enabled=)

    @mock_menu_examples_run = mock('MenuExamplesRun')
    @mock_menu_examples_run.stub!(:enabled=)
    @mock_menu_examples_stop = mock('MenuExamplesStop')
    @mock_menu_examples_stop.stub!(:enabled=)
    
    @mock_statusbar_passed_count = mock('StatusBarPassedCount')
    @mock_statusbar_passed_count.stub!(:hidden=)
    @mock_statusbar_pending_count = mock('StatusBarpendingCount')
    @mock_statusbar_pending_count.stub!(:hidden=)
    @mock_statusbar_failed_count = mock('StatusBarfailedCount')
    @mock_statusbar_failed_count.stub!(:hidden=)
    
    @controller = WindowController.new
    @controller.pathTextField = @mock_pathTextField
    @controller.statusBar = @mock_statusBar
    @controller.statusLabel = @mock_statusLabel
    @controller.toolbar_item_run = @mock_toolbar_item_run
    @controller.toolbar_item_path = @mock_toolbar_item_path
    @controller.menu_examples_run = @mock_menu_examples_run
    @controller.menu_examples_stop = @mock_menu_examples_stop
    @controller.statusBarPassedCount = @mock_statusbar_passed_count
    @controller.statusBarPendingCount = @mock_statusbar_pending_count
    @controller.statusBarFailedCount = @mock_statusbar_failed_count
    
    @controller.stub!(:window).and_return(@mock_window)
    @controller.stub!(:valid_bin_paths?).and_return(true)
    
    $app = mock('App')
    $app.stub!(:alert)
    $app.stub!(:default_for_key)
    $app.stub!(:default_from_key)
    $app.stub!(:file_exist?).and_return(true)
    $app.stub!(:post_notification)
    SpecRunner.stub!(:run_in_path).and_return(File.dirname(__FILE__))    
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  describe 'running specs' do
    it 'should not allow to run specs if path textfield is empty' do
      @controller.should_not_receive(:path_is_valid?)
      @mock_pathTextField.stub!(:stringValue).and_return('')
      @controller.runSpecs(nil).should be_false
    end
  
    it 'should not allow to run specs if path textfield contains an invalid path' do
      File.should_receive(:exist?).with(/invalid/)
      @mock_pathTextField.stub!(:stringValue).and_return('invalid')
      @controller.runSpecs(nil).should be_false
    end
  
    it 'should run specs with in a valid path' do
      SpecRunner.should_receive(:run_job)
      @mock_pathTextField.stub!(:stringValue).and_return(File.dirname(__FILE__))
      @controller.runSpecs(nil)
    end
    
    it 'should create a ExampleRunJob with the current app.root path and pass it to the spec_runner' do
      mock_job = mock('Job')
      ExampleRunnerJob.stub!(:new).and_return(mock_job)
      SpecRunner.should_receive(:run_job).with(mock_job)
      @mock_pathTextField.stub!(:stringValue).and_return(File.dirname(__FILE__))
      @controller.runSpecs(nil)
    end
  end
  
  describe 'stopping an example run' do
    it 'should ask the SpecRunner to terminate the current task' do
      SpecRunner.should_receive(:terminate_current_task)
      @controller.stopSpecRun(nil)      
    end
  end
  
  it 'should set status bar to indeterminate and start its animation on spec_run_preparation' do
    @mock_statusBar.should_receive(:indeterminate=).with(true)
    @mock_statusBar.should_receive(:startAnimation)
    @controller.specRunPreparation(nil)
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
  
  it 'should alert if a given path doesnt exist' do
    $app.should_receive(:alert)
    @controller.path_is_valid?('/tmp/funochnichdaoderso').should be_false
  end
  
  it 'should check valid bin paths before running a spec' do
    @controller.should_receive(:valid_bin_paths?)
    @controller.runSpecs(nil)
  end
end