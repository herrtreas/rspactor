require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_table'
require 'spec_list'
require 'spec_file'

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
    $spec_list.stub!(:file_by_index).and_return(SpecFile.new(:full_path => 'hello.rb'))
    res = @table.tableView_objectValueForTableColumn_row(nil, nil, 0)
    res.should eql('hello.rb')
  end
end