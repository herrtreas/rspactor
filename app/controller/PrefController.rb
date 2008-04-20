#
#  PrefController.rb
#  RSpactor
#
#  Created by Andreas Wolff on 18.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class PrefController < OSX::NSWindowController

  ib_outlet :panel
  
  def awakeFromNib
    $pref_controller = self
  end
  
  def showWindow(sender)  
    @panel.center unless @panel.isVisible
    @panel.makeKeyAndOrderFront(self)    
  end
  
end
