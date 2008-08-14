require 'fileutils'
require File.dirname(__FILE__) + '/../spec_helper'
require 'map'

describe Map, 'mapping without doubles' do
  before(:each) do
    @map = Map.new
    @map.root = $fpath_simple
  end
  
  it 'should create a map' do
    @map.create
    @map.files.should_not be_empty
    @map.files[$fpath_simple + '/app/test.rb'].should eql($fpath_simple + '/spec/test_spec.rb')
  end
  
  it 'should tell if a map has already been created' do
    @map.created?.should be_false
    @map.create
    @map.created?.should be_true    
  end
  
  it 'should tell if a file is valid' do
    @map.file_is_valid?('fo.exe').should be_false
    @map.file_is_valid?('vendor/fo.exe').should be_false
    @map.file_is_valid?('test.rb').should be_true
    @map.file_is_valid?('vendor/test.rb').should be_false    
  end
  
  it 'should keep files without specs (value is empty)' do
    @map.create
    @map.files[$fpath_simple + '/app/foo.rb'].should eql('')    
  end
end


describe Map, 'mapping with doubles' do
  before(:each) do
    @map = Map.new
    @map.root = $fpath_doubles
  end
  
  it 'should correctly map double named files based on its path' do
    @map.create
    @map.files.should_not be_empty
    @map.files[$fpath_doubles + '/app/views/white/index.html.haml'].should eql($fpath_doubles + '/spec/white/index.html.haml_spec.rb')
    @map.files[$fpath_doubles + '/app/views/black/index.html.haml'].should eql($fpath_doubles + '/spec/black/index.html.haml_spec.rb')
  end
  
  it 'should return all mapped spec files' do
    @map.create
    res = @map.spec_files
    res.should include($fpath_doubles + '/spec/white/index.html.haml_spec.rb')
    res.should include($fpath_doubles + '/spec/black/index.html.haml_spec.rb')
  end
end


describe Map do
  before(:each) do
    FileUtils.rm($fpath_simple + '/spec/foo_spec.rb') if File.exist?($fpath_simple + '/spec/foo_spec.rb')
    @map = Map.new
    @map.root = $fpath_simple
    @map.create
  end
  
  it 'should return the spec for a file' do
    @map[$fpath_simple + '/app/test.rb'].should eql($fpath_simple + '/spec/test_spec.rb')
  end
  
  it 'should return nil if a file has no spec' do
    @map['foo'].should be_nil
  end
  
  it 'should return <the-spec-file> if a file is a spec' do
    @map['foo_spec.rb'].should eql('foo_spec.rb')
  end  
  
  it 'should map a _new_ spec to an existing, empty file' do
    @map.files[$fpath_simple + '/app/foo.rb'].should eql('')
    spec_file = $fpath_simple + '/spec/foo_spec.rb'
    FileUtils.touch(spec_file)
    @map[spec_file].should eql(spec_file)
    @map.files[$fpath_simple + '/app/foo.rb'].should eql($fpath_simple + '/spec/foo_spec.rb')
  end
  
  it 'should find the file name matching a spec name' do
    @map.file_name_from_spec('test_spec.rb').should eql('test.rb')
    @map.file_name_from_spec('test.html.haml_spec.rb').should eql('test.html.haml')
  end
  
  it 'should find a matching file' do
    @map.file_by_spec($fpath_simple + '/spec/test_spec.rb').should eql($fpath_simple + '/app/test.rb')
    @map = Map.new
    @map.root = $fpath_doubles
    @map.create
    @map.file_by_spec($fpath_doubles + '/spec/white/index.html.haml_spec.rb').should eql($fpath_doubles + '/app/views/white/index.html.haml')    
  end
end

describe Map, 'klass' do
  before(:each) do
    $app = mock('App')
    $spec_list = mock('SpecList')
    $spec_list.stub!(:clear!)
  end
  
  it 'should create an global instance of itself' do
    Map.ensure($fpath_simple)
    sleep 0.5 #wtf.. but I'm currently not sure how to test threads
    $map.should_not be_nil
  end
  
  it 'should not create map if $map is already assigned' do
    Map.should_not_receive(:new)
    Map.ensure($fpath_simple)
  end
  
  it 'should accept a block that is invoked after creating the map' do
    $map = nil
    Map.ensure($fpath_simple) { $test = 'fu' }
    sleep 0.5 #wtf.. but I'm currently not sure how to test threads 
    $test.should eql('fu')
  end
  
  it 'should post a notification if the map location has changed' do
    $app.should_receive(:post_notification).once.with(:map_location_changed)
    Map.ensure($fpath_doubles)
    sleep 0.5 #wtf.. but I'm currently not sure how to test threads 
  end
  
  it 'should clear spec list if location has changed' do
    $map = Map.new
    $map.root = $fpath_simple    
    $spec_list.should_receive(:clear!)
    Map.ensure($fpath_doubles)
    sleep 0.5 #wtf.. but I'm currently not sure how to test threads 
  end
end