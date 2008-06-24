require 'osx/cocoa'

class DrawerController < OSX::NSWindowController
  ib_outlet :drawer, :table, :hideBox
  ib_action :hideBoxClicked
  
  def awakeFromNib
    @hideBox.state = 0
    @drawer.openOnEdge(0)
    receive :retain_focus_on_drawer,  :setFocusOnTable
  end
  
  def setFocusOnTable(notification)
    self.window.makeFirstResponder(@table)    
  end
  
  def hideBoxClicked(sender)
    $spec_list.filter = (sender.state == 1) ? :failed : :all
    $app.post_notification :file_table_reload_required
  end
  
end
