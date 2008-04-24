require 'osx/cocoa'
require 'osx/foundation'

class PrefController < OSX::NSWindowController
  include OSX

  ib_outlet :panel

  def init
    super_init
  end
  
  def awakeFromNib
    $pref_controller = self
  end
  
  def showWindow(sender)  
    @panel.center unless @panel.isVisible
    @panel.makeKeyAndOrderFront(self)    
  end
    
end
