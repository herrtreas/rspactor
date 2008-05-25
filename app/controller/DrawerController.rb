class DrawerController < OSX::NSWindowController
  include OSX
  
  ib_outlet :filesDrawer
  
  ib_action :setDrawerPosition
  ib_action :toggleDrawerVisibility
  
  
  def init
    @defaults = NSUserDefaults.standardUserDefaults
    super_init    
  end
  
  def awakeFromNib
    setAndResetDrawerState
  end
  
  def setDrawerPosition(sender)
    if sender.title == 'Left'
      sender.state = 1
      sender.menu.itemWithTitle('Right').state = 0
      edge = 0 
    else
      sender.state = 1
      sender.menu.itemWithTitle('Left').state = 0
      edge = 2
    end
    
    @filesDrawer.openOnEdge(edge)
    @defaults.setObject_forKey(edge.to_s, 'files_drawer_position')  
  end
  
  def toggleDrawerVisibility(sender)
    @filesDrawer.toggle(self)
  end
  
  def drawerDidOpen(notification)
    @defaults.setObject_forKey('true', 'drawer_is_open')      
  end

  def drawerDidClose(notification)
    @defaults.setObject_forKey('false', 'drawer_is_open')          
  end
  
  def drawerWillResizeContents_toSize(sender, to_size)
    @defaults.setObject_forKey(to_size.width, 'files_drawer_width')      
    to_size
  end
    
  
  private
  
  def setAndResetDrawerState
    if drawer_size = @defaults.stringForKey("files_drawer_width")
      size = NSSize.new
      size.width = drawer_size 
      drawer_size = size
    else
       drawer_size = @filesDrawer.contentSize
    end    
    
    @filesDrawer.setContentSize(drawer_size)
    
    if @defaults.stringForKey("drawer_is_open") == 'true'
      drawer_position = @defaults.stringForKey("files_drawer_position") || '0'
      @filesDrawer.openOnEdge(drawer_position)
      if drawer_position == '0'
        NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('221').state = 1
      else
        NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('222').state = 1
      end
    end
  end
end