require File.dirname(__FILE__) + '/../spec_helper'
require 'netbeans'

describe Netbeans do
  before(:each) do
    $app = mock('App')    
    $app.stub!(:default_from_key).and_return('netbeans')
  end
  
  it 'should open Netbeans with file and line' do
    Kernel.should_receive(:system).with('netbeans --open path.rb:3')
    Netbeans.open_file_with_line('path.rb:3')
  end
  
  it 'should get the Netbeans bin from user defaults' do
    $app.should_receive(:default_from_key).with(:nb_bin_path).and_return('/bin/netbeans')
    Kernel.should_receive(:system).with('/bin/netbeans --open path.rb:3')
    Netbeans.open_file_with_line('path.rb:3')
  end
end