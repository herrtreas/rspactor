require File.dirname(__FILE__) + '/../spec_helper'
require 'preferences_controller'

describe PreferencesController do
  before(:each) do
    $app = mock('App')
    $app.stub!(:default_from_key)
    $app.stub!(:default_for_key)
    @controller = PreferencesController.new
    @mock_panel = mock('Panel')
    @mock_spec_field = mock('SpecField')
    @mock_spec_field.stub!(:stringValue=)
    @mock_ruby_field = mock('RubyField')
    @mock_ruby_field.stub!(:stringValue=)
    @controller.panel = @mock_panel
    @controller.specBinPath = @mock_spec_field
    @controller.rubyBinPath = @mock_ruby_field
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
  
  it 'should set both bin path on text change' do
    @mock_spec_field.stub!(:stringValue).and_return('spec_bin')    
    @mock_ruby_field.stub!(:stringValue).and_return('ruby_bin')    
    $app.should_receive(:default_for_key).with(:spec_bin_path, 'spec_bin').once
    $app.should_receive(:default_for_key).with(:ruby_bin_path, 'ruby_bin').once
    @controller.controlTextDidChange(nil)    
  end
  
  it 'should alert if bin path is invalid'
end