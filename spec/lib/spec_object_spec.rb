require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_object'

describe SpecObject do
  it 'should initialize with an arbitrary number of params' do
    s = SpecObject.new(:state => :test, :message => 'Mu')
    s.state.should eql(:test)
    s.message.should eql('Mu')
  end
  
  it 'should create an id on initialize' do
    s = SpecObject.new
    s.id.should_not be_nil
  end
  
  it 'should provide a full name (example_group_name + name) on to_s' do
    s = SpecObject.new(:example_group_name => 'test', :name => 'message')
    s.to_s.should eql('test message')
  end
  
  it 'should make the first word upper case in message' do
    s = SpecObject.new(:message => 'test')
    s.message.should eql('Test')
  end
  
  it 'should parse the backtrace' do
    bt = ['/path/finder.rb:25', '/test/home/path/test_spec.rb:10', '/path/runner.rb:56']
    s = SpecObject.new(:backtrace => bt)
    s.file.should eql('test_spec.rb')
    s.line.should eql(10)
    s.full_file_path.should eql('/test/home/path/test_spec.rb')
  end
  
  it 'should use the first line from backtrace if no spec files was involed' do
    bt = ['/test/home/path/noexampleincluded.rb:10']
    s = SpecObject.new(:backtrace => bt)
    s.file.should eql('noexampleincluded.rb')
    s.line.should eql(10)
    s.full_file_path.should eql('/test/home/path/noexampleincluded.rb')
  end
  
  it 'should parse the source' do
    bt = [File.dirname(__FILE__) + '/../fixtures/maps/simple/spec/test_spec.rb:1']
    s = SpecObject.new(:backtrace => bt)
    s.source.size.should be(2)
    s.source[0].should eql("describe 'test' do")
    s.source[1].should eql("end")
  end

end
