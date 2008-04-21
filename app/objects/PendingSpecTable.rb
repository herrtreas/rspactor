require 'osx/cocoa'

class PendingSpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :specsTable
  ib_action :receiveAction
    
  def init(controller)
    @@controller = controller
    self
  end
  
  def awakeFromNib
    $pendingSpecsTableView = @specsTable
    $pendingSpecsTableView.reloadData
    NSNotificationCenter.defaultCenter.objc_send :addObserver, self, 
           :selector, "updateDetailView:",
           :name, :NSTableViewSelectionDidChangeNotification, 
           :object, @specsTable
    
  end
  
  def reload!
    $pendingSpecsTableView.reloadData
  end
  
  def clearSelection
    $pendingSpecsTableView.deselectAll(self)
  end
  
  def numberOfRowsInTableView(specTable)
    $pending_specs.size
  end

  def tableView_objectValueForTableColumn_row(specTable, specTableColumn, rowIndex)
    $pending_specs[rowIndex].to_s
  end

  def updateDetailView(sender)
    spec = $pending_specs[sender.object.selectedRow]
    @@controller.updateDetailView(spec.description) if spec
  end
  
end
