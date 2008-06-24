require 'osx/cocoa'

class DrawerController < OSX::NSWindowController
  ib_outlet :drawer, :table
  
  def awakeFromNib
    @drawer.openOnEdge(0)
    receive :retain_focus_on_drawer,  :setFocusOnTable
  end
  
  def setFocusOnTable(notification)
    self.window.makeFirstResponder(@table)    
  end
end
