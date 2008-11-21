require File.dirname(__FILE__) + '/../spec_helper'
require 'listener'

describe Listener do
  it 'should define a global callback to use with fsevents callbacks' do
    Listener.class_variables.should include('@@callback')
  end
  
  it 'should return if a listener was already defined' do
    Listener.stub!(:already_running?).and_return(true)
    Listener.init($fpath_simple).should be_false
  end
  
  it 'should know if another instance is already running' do
    lambda do
      Listener.init($fpath_simple)
      Listener.already_running?.should be_true
    end
  end
end