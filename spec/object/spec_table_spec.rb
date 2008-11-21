require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_table'
require 'example_file'
require 'example_files'

describe SpecTable do
  before(:each) do
    @mock_specsTable = mock('SpecsTable')
    @table = SpecTable.new
    @table.specsTable = @mock_specsTable
  end
  
  it 'should reload after a single spec has been processed' do
    @table.should_receive(:reload!)
    @table.specRunFinishedSingleSpec(nil)
  end
  
  it 'should reload the data from specsTable`s source' do
    @mock_specsTable.should_receive(:reloadData)
    @table.reload!
  end
  
  describe 'with additional information for files' do
  
    before(:each) do
      @example_file = ExampleFile.new(:path => '/path/to/hello.rb')
      ExampleFiles.stub!(:file_by_index).and_return(@example_file)
    end
  
    it 'should send out the base file name for a single column on app request' do
      @example_file.stub!(:passed?).and_return(true) 
      res = @table.tableView_objectValueForTableColumn_row(nil, nil, 0)
      res.string.should include('Hello.rb')
    end
  
    describe 'colored by spec state' do
      it 'should mark a failed file red' do
        @example_file.stub!(:failed?).and_return(true)
        color = @table.color_by_state(@example_file)
        color.should == { :red => 0.8, :green => 0.1, :blue => 0.1 }
      end
  
      it 'should mark a pending file orange' do
        @example_file.stub!(:pending?).and_return(true)
        color = @table.color_by_state(@example_file)
        color.should == { :red => 0.9, :green => 0.6, :blue => 0}
      end
  
      it 'should mark a passed file green' do
        @example_file.stub!(:passed?).and_return(true)
        color = @table.color_by_state(@example_file)
        color.should == { :red => 0.0, :green => 0.3, :blue => 0.0}
      end  
    end
    
  end
end