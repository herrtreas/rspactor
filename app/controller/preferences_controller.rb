require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  ib_outlet :panel, :specBinPath, :rubyBinPath, :tmBinPath, :nbBinPath, :toolbar, :binariesPrefsView, :editorPrefsView, :updatePrefsView
  ib_action :toolbarItemClicked
  
    
  def initialize
    unless $app.default_from_key(:spec_bin_path, nil)
      spec_bin_path = `/usr/bin/which spec`
      $app.default_for_key(:spec_bin_path, spec_bin_path) unless spec_bin_path.empty?
    end
    unless $app.default_from_key(:ruby_bin_path, nil)
      ruby_bin_path = `/usr/bin/which ruby`
      $app.default_for_key(:ruby_bin_path, ruby_bin_path) unless ruby_bin_path.empty?
    end
    unless $app.default_from_key(:tm_bin_path, nil)
      tm_bin_path = `/usr/bin/which mate`
      $app.default_for_key(:tm_bin_path, tm_bin_path) unless tm_bin_path.empty?
    end
    receive :file_doesnot_exist,  :showPathErrorAlert
  end
  
  def awakeFromNib
    set_default_spec_bin_path
    set_default_ruby_bin_path
    set_default_tm_bin_path
    set_default_nb_bin_path
    initToolbar
  end

  def showWindow(sender)
    @panel.makeKeyAndOrderFront(self)
  end
  
  def set_default_spec_bin_path
    @specBinPath.stringValue = $app.default_from_key(:spec_bin_path, '/usr/bin/spec')
  end
  
  def set_default_ruby_bin_path
    @rubyBinPath.stringValue = $app.default_from_key(:ruby_bin_path, '/usr/bin/ruby')
  end

  def set_default_tm_bin_path
    @tmBinPath.stringValue = $app.default_from_key(:tm_bin_path, '/usr/bin/mate')
  end

  def set_default_nb_bin_path
    @nbBinPath.stringValue = $app.default_from_key(:nb_bin_path, '/usr/bin/netbeans')
  end
  
  def controlTextDidEndEditing(notification)
    check_path_and_set_default(:spec_bin_path, @specBinPath.stringValue)  if notification.object.stringValue == @specBinPath.stringValue
    check_path_and_set_default(:ruby_bin_path, @rubyBinPath.stringValue)  if notification.object.stringValue == @rubyBinPath.stringValue
    check_path_and_set_default(:tm_bin_path, @tmBinPath.stringValue)      if notification.object.stringValue == @tmBinPath.stringValue
    check_path_and_set_default(:nb_bin_path, @nbBinPath.stringValue)      if notification.object.stringValue == @nbBinPath.stringValue
    
    # This is to fill textfields with chomped, stripped values
    set_default_spec_bin_path
    set_default_ruby_bin_path
    set_default_tm_bin_path
  end
  
  def check_path_and_set_default(key, path)
    path = path.chomp.strip
    $app.default_for_key(key, path) if $app.file_exist?(path) or path.empty?
  end
  
  def showPathErrorAlert(notification)
    path = notification.userInfo.first
    return unless path == @specBinPath.stringValue.chomp.strip || path == @rubyBinPath.stringValue.chomp.strip || path == @tmBinPath.stringValue.chomp.strip
    
    alert = NSAlert.alloc.init
    alert.alertStyle = OSX::NSCriticalAlertStyle
    alert.messageText = "The executable path '#{path}' doesn't exist.\nPlease check your preferences."
    alert.runModal
  end
  
  def initToolbar
    @toolbar.selectedItemIdentifier = @toolbar.items[0].itemIdentifier
    window.setContentSize @binariesPrefsView.frame.size 
    window.contentView.addSubview @binariesPrefsView
    window.title = "Executables Preferences"
    @currentViewTag = 0
    window.contentView.wantsLayer = true    
  end
  
  def toolbarSelectableItemIdentifiers(toolbar)
    @toolbaridents ||= begin
      @toolbar.items.collect {|i| i.itemIdentifier }
    end
  end
    
  def toolbarItemClicked(sender)
    tag =  sender.tag
    view, title = self.viewForTag(tag)
    previousView, prevTitle = self.viewForTag(@currentViewTag)
    @currentViewTag = tag
    newFrame = self.newFrameForNewContentView(view)
    window.title = "#{title} Preferences"
    NSAnimationContext.beginGrouping
      window.contentView.animator.replaceSubview_with(previousView, view)
      window.animator.setFrame_display newFrame, true
    NSAnimationContext.endGrouping    
  end
  
  def viewForTag(tag)
    case tag
      when 0: [@binariesPrefsView,  "Executables"]
      when 1: [@editorPrefsView, "Editor"]
      when 2: [@updatePrefsView, "Update"]
    end
  end
  
  def newFrameForNewContentView(view)
    newFrameRect = window.frameRectForContentRect(view.frame)
    oldFrameRect = window.frame
    newSize = newFrameRect.size
    oldSize = oldFrameRect.size
    frame = window.frame
    frame.size = newSize
    frame.origin.y = frame.origin.y - (newSize.height - oldSize.height)
    frame
  end  
end