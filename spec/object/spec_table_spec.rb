require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_table'

describe SpecTable do
  before(:each) do
    @mock_specsTable = mock('SpecsTable')
    @table = SpecTable.new
    @table.specsTable = @mock_specsTable
    $spec_list = SpecList.new
  end
  
  it 'should reload after a single spec has been processed' do
    @table.should_receive(:reload!)
    @table.specRunFinishedSingleSpec(nil)
  end
  
  it 'should reload the data from specsTable`s source' do
    @mock_specsTable.should_receive(:reloadData)
    @table.reload!
  end
  
  it 'should send out data size on app request' do
    @table.numberOfRowsInTableView(nil)
  end
  
  it 'should send out the base file name for a single column on app request' do
    mock_spec_file = mock('SpecFile', :failed? => false, :pending? => false, :name => 'hello.rb')
    $spec_list.stub!(:file_by_index).and_return(mock_spec_file)
    res = @table.tableView_objectValueForTableColumn_row(nil, nil, 0)
    res.string.should include('hello.rb')
  end
  
  it 'should return a color by file state' do
    mock_spec_file = mock('SpecFile', :failed? => true, :pending? => false)
    color = @table.color_by_state(mock_spec_file)
    color.should == { :red => 0.8, :green => 0.1, :blue => 0.1 }
  end
  
  it 'should return orange color for a pending spec' do
    mock_spec_file = mock('SpecFile', :pending? => true, :failed? => false)
    color = @table.color_by_state(mock_spec_file)
    color.should == { :red => 0.9, :green => 0.6, :blue => 0}
  end
end