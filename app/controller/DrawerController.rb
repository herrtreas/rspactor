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
      edge = 0 
    else
      edge = 2
    end
    
    @filesDrawer.openOnEdge(edge)
    @defaults.setObject_forKey(edge.to_s, 'files_drawer_position')  
    set_current_position_from_defaults
  end
  
  def toggleDrawerVisibility(sender)
    set_current_position_from_defaults
    if @filesDrawer.state == 0
      @filesDrawer.openOnEdge(@filesDrawer.preferredEdge)
    else
      @filesDrawer.close
    end
  end
  
  def drawerWillOpen(notification)
    set_current_position_from_defaults
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
    set_current_position_from_defaults    
    drawer_open_by_default  
  end
  
  def set_current_position_from_defaults
    drawer_position = @defaults.stringForKey("files_drawer_position")
    drawer_position = '0' if drawer_position.nil?    
    if drawer_position == '0'
      NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('221').state = 1
      NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('222').state = 0      
    else
      NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('222').state = 1
      NSApp.menu.itemWithTag('2').submenu.itemWithTag('22').submenu.itemWithTag('221').state = 0      
    end      
    @filesDrawer.preferredEdge = drawer_position.to_i      
  end
    
  def drawer_open_by_default
    drawer_open = @defaults.stringForKey("drawer_is_open")
    drawer_open = 'true' if drawer_open.nil?    
    @filesDrawer.openOnEdge(@filesDrawer.preferredEdge) if drawer_open == 'true'
  end
  
end