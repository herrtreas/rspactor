require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_file'
require 'spec_object'

describe SpecFile do
  it 'should initialize with an arbitrary number of params' do
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [SpecObject.new(:name => 'huhu')])
    file.full_path.should eql('/home/test.rb')
    file.specs.first.name.should eql('huhu')
  end
  
  it 'should split the full file path into the file_name' do
    file = SpecFile.new(:full_path => '/home/test.rb')
    file.name.should eql('test.rb')
  end
  
  it 'should have a << method to add specs' do
    file = SpecFile.new(:full_path => '/home/test.rb')
    lambda do
      file << SpecObject.new
    end.should change(file, :spec_count)
  end
  
  it 'should replace a spec file if it already exists in the collection' do
    so1 = SpecObject.new(:name => 'test', :state => :passed)
    so2 = SpecObject.new(:name => 'test', :state => :failed)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so1])
    lambda do
      file << so2
    end.should_not change(file, :spec_count)
    file.specs.first.state.should eql(:failed)
  end
  
  it 'should have a spec_count' do
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => ['1', '2', '3'])
    file.spec_count.should eql(3)
  end
  
  it 'should know if it contains a spec' do
    so = SpecObject.new
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so])
    file.contains_spec?(so).should be_true    
  end
  
  it 'should return if it contains failed specs' do
    so = SpecObject.new(:state => :failed)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so])
    file.failed?.should be_true
  end

  it 'should return if it contains pending specs but no failed' do
    so = SpecObject.new(:state => :pending)
    so2 = SpecObject.new(:state => :failed)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so])
    file.pending?.should be_true
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so, so2])
    file.pending?.should be_false
  end
  
  it 'should return specs with order (failed, pending, passed)' do
    so_passed = SpecObject.new(:name => 'test', :state => :passed)
    so_failed = SpecObject.new(:name => 'test2', :state => :failed)
    so_pending = SpecObject.new(:name => 'test3', :state => :pending)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so_passed, so_failed, so_pending])
    file.specs[0].name.should eql('test2')
    file.specs[1].name.should eql('test3')
    file.specs[2].name.should eql('test')
  end
end