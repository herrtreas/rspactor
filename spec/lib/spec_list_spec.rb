require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_list'
require 'spec_object'
require 'spec_file'

describe SpecList do
  
  before(:each) do
    @spec_list = SpecList.new
    @spec = SpecObject.new
    @spec.state = :passed
    @spec.name = 'it should behave like zorro'
    @spec.full_file_path = '/tmp/test/spec.rb'
    @failed_spec = SpecObject.new
    @failed_spec.state = :failed
    @failed_spec.name = 'it should not work'
    @failed_spec.full_file_path = '/tmp/test/failed_spec.rb'
    @pending_spec = SpecObject.new
    @pending_spec.state = :pending
    @pending_spec.name = 'it should look as good as <tinna>'
    @pending_spec.full_file_path = '/tmp/test/pending_spec.rb'
    @pending2_spec = SpecObject.new
    @pending2_spec.state = :pending
    @pending2_spec.name = 'it should look as good as <paris>'
    @pending2_spec.full_file_path = '/tmp/test/pending_spec.rb'
    @spec_list << @spec
    @spec_list << @failed_spec
    @spec_list << @pending_spec
    @spec_list << @pending2_spec
  end
  
  it 'should add a spec to the list' do
    @spec_list.size.should eql(3)
  end
    
  it 'should filter the list by state' do
    @spec_list.filter_by(:failed).first.specs.should include(@failed_spec)
  end
  
  it 'should replace existing specs' do
    lambda do
      spec_index = @spec_list.index(@spec)
      dolly_spec = @spec.clone
      dolly_spec.state = :cloned
      @spec_list << dolly_spec
      @spec_list.at(spec_index).state.should eql(:cloned)
    end.should_not change(@spec_list, :size)
  end
  
  it 'should get the total spec count (yet to run)' do
    @spec_list.total_spec_count = 10
    @spec_list.total_spec_count.should eql(10)
  end
  
  it 'should get the processed spec count' do
    @spec_list.processed_spec_count += 1
    @spec_list.processed_spec_count.should eql(1)
  end

  it 'should clear run stats' do
    @spec_list.total_spec_count = 10
    @spec_list.processed_spec_count = 11
    @spec_list.clear_run_stats
    @spec_list.total_spec_count.should eql(0)
    @spec_list.processed_spec_count.should eql(0)
  end
  
  it 'should get a spec by index' do
    @spec_list[0].should eql(@spec)
  end
  
  it 'should list all files' do
    @spec_list.files.size.should eql(3)
  end
    
  it 'should find a file by index' do
    @spec_list.file_by_index(1).full_path.should eql('/tmp/test/failed_spec.rb')
  end
  
  it 'should find a already added file' do
    file = SpecFile.new(:full_path => '/tmp/test/pending_spec.rb')
    @spec_list.contains_file?(file).should be_true
  end
  
  it 'should find a file object by full_path' do
    @spec_list.file_by_path('/tmp/test/pending_spec.rb').full_path.should eql('/tmp/test/pending_spec.rb')
  end
  
  it 'should find a spec by file' do
    @spec_list.file_by_spec(@pending2_spec).full_path.should eql('/tmp/test/pending_spec.rb')
  end
  
  it 'should find the index by file' do
    file = SpecFile.new(:full_path => '/tmp/test/pending_spec.rb')    
    @spec_list.index_by_file(file).should eql(2)
  end
  
  it 'should find the (file)index by spec' do
    @spec_list.index_by_spec(@pending2_spec).should eql(2)
  end
  
  it 'should have a filter property' do
    @spec_list.filter.should eql(:all)
    @spec_list.filter = :failed
  end
end