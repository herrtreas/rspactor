require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_runner'
require 'map'
require 'listener'

describe SpecRunner do
  before(:each) do
    $app = mock('App')    
    $app.stub!(:post_notification)
    $app.stub!(:default_from_key).and_return('')
    SpecRunner.stub!(:command_running?).and_return(false)
  end
  
  it 'should ensure a valid map before running specs' do
    puts "TESTTESTTEST"
    Map.should_receive(:ensure)
    SpecRunner.run_in_path($fpath_simple)
  end
  
  it 'should validate(start) the listener' do
    lambda do
      Listener.should_receive(:init)
      SpecRunner.run_in_path($fpath_simple)    
    end
  end
  
  it 'should run all specs in path' do
    Map.ensure($fpath_simple)
    $map.should_receive(:spec_files).and_return([])
    SpecRunner.run_all_specs_in_path
  end
  
  it 'should return if there are no locations to spec in' do
    $map.should_receive(:spec_files).and_return([])
    SpecRunner.run_all_specs_in_path.should be_false
  end
  
  it 'should create the spec runner command' do
    res = SpecRunner.create_runner_arguments(%w{test test2})
    res.should include('test')
    res.should include('test2')
    res.should include('-fRSpactorFormatter:STDOUT')
  end
  
  it 'should use "spec" binary per default' do
    $app.should_receive(:default_from_key).with(:spec_bin_path).and_return('spec_bin')
    SpecRunner.prepare_running_environment([])[0].should eql('spec_bin')
  end
  
  it 'should use "script/spec" if available' do
    $app.should_receive(:default_from_key).with(:ruby_bin_path).twice.and_return('ruby_bin')
    $map.root = $fpath_rails
    SpecRunner.prepare_running_environment([])[0].should eql("ruby_bin") 
    SpecRunner.prepare_running_environment([])[1].should eql(["#{$map.root}/script/spec"])
  end
  
  it 'should run specs for specific files' do
    SpecRunner.should_receive(:run_command)
    SpecRunner.run_specs_for_files(['test_spec.rb'])    
  end
  
  it 'should cancel spec run for specific files if no files where provided' do
    SpecRunner.should_not_receive(:run_command)
    SpecRunner.run_specs_for_files([]).should be_false
  end
  
  it 'should post a "spec_run_start" notification' do
    SpecRunner.stub!(:run_command)
    $app.should_receive(:post_notification).with(:spec_run_invoked)
    SpecRunner.run_specs_for_files(['test_spec.rb'])
  end
  
  it 'should skip the command running if another command has not finished yet' do
    SpecRunner.stub!(:command_running?).and_return(true)
    SpecRunner.run_command('ls').should be_false
  end
end
