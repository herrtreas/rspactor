require 'osx/cocoa'

class FailedSpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :specsTable
  ib_action :receiveAction
    
  def init(controller)
    @@controller = controller
    self
  end
  
  def awakeFromNib
    $failedSpecsTableView = @specsTable
    $failedSpecsTableView.reloadData
    NSNotificationCenter.defaultCenter.objc_send :addObserver, self, 
           :selector, "updateDetailView:",
           :name, :NSTableViewSelectionDidChangeNotification, 
           :object, @specsTable
    
  end
  
  def selectFirstEntry
    $failedSpecsTableView.selectRowIndexes_byExtendingSelection(NSIndexSet.new.initWithIndex(0), false)
  end
  
  def reload!
    $failedSpecsTableView.reloadData
  end
  
  def clearSelection
    $failedSpecsTableView.deselectAll(self)
  end
  
  def numberOfRowsInTableView(specTable)
    $failed_specs.size
  end

  def tableView_objectValueForTableColumn_row(specTable, specTableColumn, rowIndex)
    $failed_specs[rowIndex].to_s
  end

  def updateDetailView(sender)
    spec = $failed_specs[sender.object.selectedRow]
    $details.setContentFromSpec(spec) if spec
  end
  
end
