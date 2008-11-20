require 'osx/cocoa'

class DrawerController < OSX::NSWindowController
  ib_outlet :drawer, :table, :hideBox
  ib_action :hideBoxClicked
  
  def awakeFromNib
    restoreSizeFromLastSession
    @hideBox.state = $app.default_from_key(:hide_box_state, 0)
    set_filter(@hideBox.state)
    @drawer.openOnEdge(0)
    receive :retain_focus_on_drawer,  :setFocusOnTable
  end
  
  def setFocusOnTable(notification)
    self.window.makeFirstResponder(@table)    
  end
  
  def hideBoxClicked(sender)
    $app.default_for_key(:hide_box_state, sender.state)
    set_filter(sender.state)
    $app.post_notification :file_table_reload_required
  end

  def drawerWillResizeContents_toSize(sender, to_size)
    $app.default_for_key(:files_drawer_width, to_size.width)
    to_size
  end
  
  def restoreSizeFromLastSession
    drawer_size = $app.default_from_key(:files_drawer_width)
    if !drawer_size.empty?
      size = OSX::NSSize.new
      size.width = drawer_size
      drawer_size = size
    else
       drawer_size = @drawer.contentSize
    end    
    @drawer.setContentSize(drawer_size)    
  end
  
  def set_filter(state)
    ExampleFiles.filter = (state == 1) ? :failed : :all    
  end
end
