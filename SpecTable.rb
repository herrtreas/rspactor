require 'osx/cocoa'

class SpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :failedSpecsTable
  ib_action :receiveAction
    
  def init(controller)
    @@controller = controller
    self
  end
  
  def awakeFromNib
    $failedSpecsTableView = @failedSpecsTable
    $failedSpecsTableView.reloadData
    NSNotificationCenter.defaultCenter.objc_send :addObserver, self, 
           :selector, "updateDetailView:",
           :name, :NSTableViewSelectionDidChangeNotification, 
           :object, @failedSpecsTable
    
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
    @@controller.updateDetailView(spec.description) if spec
  end
  
end
