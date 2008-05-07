require File.join(File.dirname(__FILE__), '/../../../spec_helper')
require File.join(File.dirname(__FILE__), '/../../../../app/lib/core/map')

describe RSpactor::Core::Map, 'mapping without doubles' do
  before(:each) do
    @map = RSpactor::Core::Map.new
    @map.root = $fpath_simple
  end
  
  it 'should create a map' do
    @map.create
    @map.files.should_not be_empty
    @map.files[$fpath_simple + '/app/test.rb'].should eql($fpath_simple + '/spec/test_spec.rb')
  end
end


describe RSpactor::Core::Map, 'mapping with doubles' do
  before(:each) do
    @map = RSpactor::Core::Map.new
    @map.root = $fpath_doubles
  end
  
  it 'should correctly map double named files based on its path' do
    @map.create
    @map.files.should_not be_empty
    @map.files[$fpath_doubles + '/app/views/white/index.html.haml'].should eql($fpath_doubles + '/spec/white/index.html.haml_spec.rb')
    @map.files[$fpath_doubles + '/app/views/black/index.html.haml'].should eql($fpath_doubles + '/spec/black/index.html.haml_spec.rb')
  end
end


describe RSpactor::Core::Map do
  before(:each) do
    @map = RSpactor::Core::Map.new
    @map.root = $fpath_simple
    @map.create    
  end
  
  it 'should return the spec for a file' do
    @map[$fpath_simple + '/app/test.rb'].should eql($fpath_simple + '/spec/test_spec.rb')
  end
  
  it 'should return nil if a file has no spec' do
    @map['foo'].should be_nil
  end
end