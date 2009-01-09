require File.dirname(__FILE__) + '/../spec_helper'
require 'example_file'

describe ExampleFile do
  before(:each) do
    $app = mock('App')
    $app.stub!(:root)
    Notification.stub!(:send)
    @example_file = ExampleFile.new(:path => '/path/to/hello.rb')
  end
  
  it 'should attach the failed spec count the file count' do
    @example_file.stub!(:spec_count).with(:failed).and_return(3)
    @example_file.name(:include => :spec_count).should include('3')
  end
  
  it 'should reset modification times if a spec is added or replaced' do
    lambda do
      @example_file.add_spec(SpecObject.new(:backtrace => ['test.rb']))
    end.should change(@example_file, :mtime)
  end
  
  describe 'with backtraces' do
    before(:each) do
      @old_spec = SpecObject.new(:backtrace => ['test.rb:10', 'test2.rb:5', 'spec.rb:5'])
      @new_spec = SpecObject.new(:backtrace => ['spec.rb:5'])      
      @example_file.add_spec(@old_spec)
    end
    
    it 'should use old_specs full_file_path if the new_specs backtrace doesnt contain the old_specs full_file_path' do
      @example_file.add_spec(@new_spec)
      @example_file.specs.should have(1).record
      @example_file.specs.first.full_file_path.should eql('test.rb')
    end
  end
end