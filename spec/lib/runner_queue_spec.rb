require File.dirname(__FILE__) + '/../spec_helper'
require 'runner_queue'
require 'example_file'

describe RunnerQueue do
  before(:each) do
    @queue = RunnerQueue.new
    @example_file = ExampleFile.new(:path => '/path/to/file.rb')
    @queue << @example_file.path
  end
  
  it 'should add an example_file' do
    @queue.size.should eql(1)
  end
  
  it 'should add a bulk if files' do
    @queue.add_bulk(['/test1', '/test2'])
    @queue.size.should eql(3)
  end
  
  it 'should only contain 1 copy of each path' do
    @queue << @example_file.path
    @queue.size.should eql(1)
    @queue.add_bulk(['/test1', '/test1'])
    @queue.size.should eql(2)
  end
  
  it 'should now if its empty' do
    @queue.should_not be_empty
  end
  
  describe 'delivering the next waiting example_files' do
    it 'should concat all waiting files' do
      @queue << '/test'
      @queue.next_files.should eql([@example_file.path, '/test'])
      @queue.size.should eql(0)
    end
    
    it 'should return nil if no more files are waiting' do
      @queue.next_files
      @queue.next_files.should be_empty
    end
  end
end