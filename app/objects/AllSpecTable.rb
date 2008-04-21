require 'osx/cocoa'

class AllSpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :specsTable
  ib_action :receiveAction
    
  def init(controller)
    @@controller = controller
    self
  end
  
  def awakeFromNib
    $allSpecsTableView = @specsTable
    $allSpecsTableView.reloadData
    NSNotificationCenter.defaultCenter.objc_send :addObserver, self, 
           :selector, "updateDetailView:",
           :name, :NSTableViewSelectionDidChangeNotification, 
           :object, @specsTable
    
  end
  
  def reload!
    $allSpecsTableView.reloadData
  end
  
  def clearSelection
    $allSpecsTableView.deselectAll(self)
  end
  
  def numberOfRowsInTableView(specTable)
    $all_specs.size
  end

  def tableView_objectValueForTableColumn_row(specTable, specTableColumn, rowIndex)
    $all_specs[rowIndex].to_s
  end

  def updateDetailView(sender)
    spec = $all_specs[sender.object.selectedRow]
    $details.setContentFromSpec(spec) if spec
  end
  
end
