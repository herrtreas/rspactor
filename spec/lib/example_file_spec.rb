require File.dirname(__FILE__) + '/../spec_helper'
require 'example_file'

describe ExampleFile do
  before(:each) do
    @example_file = ExampleFile.new(:path => '/path/to/hello.rb')
  end
  
  it 'should attach the failed spec count the file count' do
    @example_file.stub!(:spec_count).with(:failed).and_return(3)
    @example_file.name(:include => :spec_count).should include('3')
  end
end