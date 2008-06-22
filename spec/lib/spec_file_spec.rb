require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_file'

describe SpecFile do
  it 'should initialize with an arbitrary number of params' do
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => ['huhu'])
    file.full_path.should eql('/home/test.rb')
    file.specs.should eql(['huhu'])
  end
  
  it 'should split the full file path into the file_name' do
    file = SpecFile.new(:full_path => '/home/test.rb')
    file.name.should eql('test.rb')
  end
  
end