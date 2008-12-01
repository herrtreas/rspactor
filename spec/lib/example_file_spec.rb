require File.dirname(__FILE__) + '/../spec_helper'
require 'example_file'

describe ExampleFile do
  before(:each) do
    $app = mock('App')
    $app.stub!(:root)
    $app.stub!(:post_notification)
    @example_file = ExampleFile.new(:path => '/path/to/hello.rb')
  end
  
  it 'should attach the failed spec count the file count' do
    @example_file.stub!(:spec_count).with(:failed).and_return(3)
    @example_file.name(:include => :spec_count).should include('3')
  end
  
  it 'should reset modification times if a spec is added or replaced' do
    lambda do
      @example_file.add_spec(SpecObject.new)
    end.should change(@example_file, :mtime)
  end
end