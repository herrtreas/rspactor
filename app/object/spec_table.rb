require 'osx/cocoa'

class SpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :specsTable
  
  def awakeFromNib
    receive :spec_run_example_passed,   :specRunFinishedSingleSpec
    receive :spec_run_example_pending,  :specRunFinishedSingleSpec
    receive :spec_run_example_failed,   :specRunFinishedSingleSpec
    receive :first_failed_spec,         :markFileContainingFirstFailedSpec
  end
  
  def specRunFinishedSingleSpec(notification)
    reload!
  end
  
  def markFileContainingFirstFailedSpec(notification)
    index = $spec_list.index_by_spec(notification.userInfo.first)
    $LOG.debug "Marking: #{index}"
    @specsTable.selectRowIndexes_byExtendingSelection(NSIndexSet.new.initWithIndex(index), true)
  end
  
  def reload!
    @specsTable.reloadData
  end
  
  # def clearSelection
  #   $allSpecsTableView.deselectAll(self)
  # end
  
  def numberOfRowsInTableView(specTable)
    $spec_list.files.size
  end

  def tableView_objectValueForTableColumn_row(specTable, specTableColumn, rowIndex)
    return unless $spec_list && file = $spec_list.file_by_index(rowIndex)
    file.name
  end

end
