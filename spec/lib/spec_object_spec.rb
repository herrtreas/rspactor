require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_object'

describe SpecObject do
  it 'should initialize with an arbitrary number of params' do
    s = SpecObject.new(:state => :test, :message => 'Mu')
    s.state.should eql(:test)
    s.message.should eql('Mu')
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
    bt = ['/test/home/path/spec.rb:10']
    s = SpecObject.new(:backtrace => bt)
    s.file.should eql('spec.rb')
    s.line.should eql(10)
    s.full_file_path.should eql('/test/home/path/spec.rb')
  end
  
  it 'should parse the source' do
    bt = [File.dirname(__FILE__) + '/../fixtures/maps/simple/spec/test_spec.rb:1']
    s = SpecObject.new(:backtrace => bt)
    s.source.size.should be(2)
    s.source[0].should eql("describe 'test' do")
    s.source[1].should eql("end")
  end

end
