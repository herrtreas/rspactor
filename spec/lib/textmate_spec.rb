require File.dirname(__FILE__) + '/../spec_helper'
require 'textmate'
require 'defaults'

describe TextMate do
  before(:each) do
    $app = mock('App')    
    Defaults.stub!(:get).and_return('mate')
  end
  
  it 'should open TM with file and line' do
    Kernel.should_receive(:system).with('mate --line 3 path.rb')
    TextMate.open_file_with_line('path.rb:3')
  end
  
  it 'should get the TM bin from user defaults' do
    Defaults.should_receive(:get).with(:editor_bin_path).and_return('/bin/mate')
    Kernel.should_receive(:system).with('/bin/mate --line 3 path.rb')
    TextMate.open_file_with_line('path.rb:3')
  end
end