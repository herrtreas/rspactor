require 'osx/cocoa'

class DrawerController < OSX::NSWindowController
  ib_outlet :drawer
  
  def awakeFromNib
    @drawer.openOnEdge(0)
  end
end
