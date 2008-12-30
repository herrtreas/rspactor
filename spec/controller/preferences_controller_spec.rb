require File.dirname(__FILE__) + '/../spec_helper'
require 'preferences_controller'

describe PreferencesController do
  before(:each) do
    $app = mock('App')
    $app.stub!(:default_from_key)
    $app.stub!(:default_for_key)
    $app.stub!(:file_exist?)
    @controller = PreferencesController.new
    @mock_panel = mock('Panel')
    @mock_spec_field = mock('SpecField', :stringValue => '')
    @mock_spec_field.stub!(:stringValue=)
    @mock_ruby_field = mock('RubyField', :stringValue => '')
    @mock_ruby_field.stub!(:stringValue=)
    @mock_editor_field = mock('EditorField', :stringValue => '')
    @mock_editor_field.stub!(:stringValue=)
    @mock_spec_warning = mock('SpecWarning')
    @mock_spec_warning.stub!(:hidden=)
    @mock_spec_warning.stub!(:toolTip=)    
    @mock_ruby_warning = mock('RubyWarning')
    @mock_ruby_warning.stub!(:hidden=)
    @mock_ruby_warning.stub!(:toolTip=)
    @mock_editor_warning = mock('EditorWarning')
    @mock_editor_warning.stub!(:hidden=)
    @mock_editor_warning.stub!(:toolTip=)
    @mock_generals_rerun_specs.stub!(:state=)
    @controller.panel = @mock_panel
    @controller.specBinPath = @mock_spec_field
    @controller.rubyBinPath = @mock_ruby_field
    @controller.editorBinPath = @mock_editor_field
    @controller.specBinWarning = @mock_spec_warning
    @controller.rubyBinWarning = @mock_ruby_warning
    @controller.editorBinWarning = @mock_editor_warning
    @controller.generalsRerunSpecsCheckBox = @mock_generals_rerun_specs
    @controller.stub!(:initToolbar)
    @controller.stub!(:initEditorPrefView)
    @controller.stub!(:initSpeechPrefView)
    @controller.stub!(:validatePreferences)
  end
  
  it 'should be an OSX::NSObject' do
    @controller.should be_kind_of(OSX::NSWindowController)
  end
  
  it 'should show the panel' do
    @mock_panel.should_receive(:makeKeyAndOrderFront)
    @controller.showWindow(nil)
  end
  
  it 'should read the default_spec_bin on wakeup' do
    @controller.should_receive(:set_default_spec_bin_path)
    @controller.awakeFromNib
  end

  it 'should read the default_ruby_bin on wakeup' do
    @controller.should_receive(:set_default_ruby_bin_path)
    @controller.awakeFromNib
  end

  it 'should read the default spec_bin_path from defaults and assign it to spec_bin textfield' do
    $app.should_receive(:default_from_key).with(:spec_bin_path, '/usr/bin/spec').and_return('/usr/bin/spec')
    @mock_spec_field.should_receive(:stringValue=).with('/usr/bin/spec')
    @controller.set_default_spec_bin_path
  end

  it 'should read the default ruby_bin_path from defaults and assign it to ruby_bin textfield' do
    $app.should_receive(:default_from_key).with(:ruby_bin_path, '/usr/bin/ruby').and_return('/usr/bin/ruby')
    @mock_ruby_field.should_receive(:stringValue=).with('/usr/bin/ruby')
    @controller.set_default_ruby_bin_path
  end

  it 'should read the default editor_bin_path from defaults and assign it to editor_bin textfield' do
    $app.should_receive(:default_from_key).with(:editor_bin_path, '/usr/bin/mate').and_return('/usr/bin/mate')
    @mock_editor_field.should_receive(:stringValue=).with('/usr/bin/mate')
    @controller.set_default_editor_bin_path
  end

  it 'should set all bin path on text change' do
    mock_notification = mock('Object')
    mock_notification.stub!(:object).and_return(@mock_spec_field)
    @mock_spec_field.stub!(:stringValue).and_return('/tmp')    
    @mock_ruby_field.stub!(:stringValue).and_return('/tmp')    
    @mock_editor_field.stub!(:stringValue).and_return('/tmp')
    $app.should_receive(:default_for_key).with(:spec_bin_path, '/tmp').once
    $app.should_receive(:default_for_key).with(:ruby_bin_path, '/tmp').once
    $app.should_receive(:default_for_key).with(:editor_bin_path, '/tmp').once
    $app.stub!(:file_exist?).and_return(true)
    @controller.stub!(:setSpeechPhrasesFromNotification)
    @controller.controlTextDidEndEditing(mock_notification)    
  end
  
  it 'should check if bin paths are valid' do
    mock_notification = mock('Object')
    mock_notification.stub!(:object).and_return(@mock_spec_field)
    @controller.should_receive(:check_path_and_set_default).exactly(3).times
    @controller.stub!(:setSpeechPhrasesFromNotification)
    @controller.controlTextDidEndEditing(mock_notification)    
  end
  
  it 'should trim and chomp bin paths' do
    mock_field = mock('Field', :stringValue => "  /usr \n\n   ")
    mock_field.should_receive(:stringValue=).with('/usr')
    @controller.check_path_and_set_default(:spec_bin_path, mock_field, @mock_spec_warning)
  end
  
  it 'should init the toolbar on awake' do
    @controller.should_receive(:initToolbar)
    @controller.awakeFromNib
  end
end