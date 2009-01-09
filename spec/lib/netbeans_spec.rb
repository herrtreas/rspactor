require File.dirname(__FILE__) + '/../spec_helper'
require 'netbeans'
require 'defaults'

describe Netbeans do
  before(:each) do
    $app = mock('App')    
    Defaults.stub!(:get).and_return('netbeans')
  end
  
  it 'should open Netbeans with file and line' do
    Kernel.should_receive(:system).with('netbeans --open path.rb:3')
    Netbeans.open_file_with_line('path.rb:3')
  end
  
  it 'should get the Netbeans bin from user defaults' do
    Defaults.should_receive(:get).with(:nb_bin_path).and_return('/bin/netbeans')
    Kernel.should_receive(:system).with('/bin/netbeans --open path.rb:3')
    Netbeans.open_file_with_line('path.rb:3')
  end
end