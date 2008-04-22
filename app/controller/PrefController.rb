#
#  PrefController.rb
#  RSpactor
#
#  Created by Andreas Wolff on 18.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'osx/foundation'

class PrefController < OSX::NSWindowController
  include OSX

  ib_outlet :panel
  ib_action :symlinkCheckBoxChanged

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
  
  def symlinkCheckBoxChanged(sender)
#     file = NSFileManager.defaultManager
#     error = NSError.new
#     NSTask.launchedTaskWithLaunchPath_arguments('sudo ls', '-la')
# #    file.createSymbolicLinkAtPath_withDestinationPath_error('/usr/bin/rspactor', File.dirname(__FILE__) + "/rspactor_bin.rb", error)
  end
  
end
