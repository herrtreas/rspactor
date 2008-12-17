require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  ib_outlet :panel, :toolbar
  ib_outlet :generalsPrefsView, :binariesPrefsView, :editorPrefsView, :updatePrefsView
  ib_outlet :specBinPath, :rubyBinPath, :editorBinPath
  ib_outlet :rubyBinWarning, :specBinWarning, :editorBinWarning
  ib_outlet :editorSelect, :editorCheckBox
  ib_outlet :generalsRerunSpecsCheckBox, :generalsSummarizeGrowl, :generalsAutoActivateSpecServer
  
  ib_action :toolbarItemClicked
  ib_action :editorCheckBoxClicked
  ib_action :editorSelectChanged
  
  
  ib_action :checkBoxClickedToSaveState do |sender|
    case sender.tag
    when 101:
      $app.default_for_key(:generals_rerun_failed_specs, sender.state)      
    when 102:
      $app.default_for_key(:generals_summarize_growl_output, sender.state)
    when 103:
      $app.default_for_key(:generals_auto_activate_spec_server, sender.state)
    end
  end
  
  ib_action :resetHiddenNotices do |sender|
    $app.default_for_key('hide_welcome_message', '0')    
  end
  
  def initialize
    unless $app.default_from_key(:spec_bin_path, nil)
      spec_bin_path = `/usr/bin/which spec`.strip.chomp
      $app.default_for_key(:spec_bin_path, spec_bin_path.chomp.strip) unless spec_bin_path.empty?
    end
    unless $app.default_from_key(:ruby_bin_path, nil)
      ruby_bin_path = `/usr/bin/which ruby`.strip.chomp
      $app.default_for_key(:ruby_bin_path, ruby_bin_path.chomp.strip) unless ruby_bin_path.empty?
    end
  end
  
  def awakeFromNib
    set_default_spec_bin_path
    set_default_ruby_bin_path
    set_default_editor_bin_path
    initToolbar
    initGeneralPrefView
    initEditorPrefView
    validatePreferences
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

  def set_default_editor_bin_path
    @editorBinPath.stringValue = $app.default_from_key(:editor_bin_path, '/usr/bin/mate')
  end
  
  def controlTextDidEndEditing(notification)
    check_path_and_set_default(:spec_bin_path, @specBinPath, @specBinWarning)  if notification.nil? || notification.object.stringValue == @specBinPath.stringValue
    check_path_and_set_default(:ruby_bin_path, @rubyBinPath, @rubyBinWarning)  if notification.nil? || notification.object.stringValue == @rubyBinPath.stringValue
    check_path_and_set_default(:editor_bin_path, @editorBinPath, @editorBinWarning)  if notification.nil? || notification.object.stringValue == @editorBinPath.stringValue
  end
  
  def check_path_and_set_default(key, path_object, warning_object)
    path_object.stringValue = path_object.stringValue.chomp.strip
    path = path_object.stringValue
    $app.default_for_key(key, path)
    if File.exist?(path)
      warning_object.hidden = true
    else
      warning_object.hidden = false
      warning_object.toolTip = "That path doesn't exist."
    end
  end
  
  def initGeneralPrefView
    @generalsRerunSpecsCheckBox.state = $app.default_from_key(:generals_rerun_failed_specs, '1')
    @generalsSummarizeGrowl.state = $app.default_from_key(:generals_summarize_growl_output, '0')
    @generalsAutoActivateSpecServer.state = $app.default_from_key(:generals_auto_activate_spec_server, '1')
  end
  
  def initToolbar
    @toolbar.selectedItemIdentifier = @toolbar.items[0].itemIdentifier
    @panel.setContentSize @generalsPrefsView.frame.size 
    @panel.contentView.addSubview @generalsPrefsView
    @panel.title = "General Preferences"
    @currentViewTag = 0
    @panel.contentView.wantsLayer = true    
  end
  
  def initEditorPrefView
    @editorCheckBox.state = $app.default_from_key(:editor_integration, '0')
    @editorSelect.removeAllItems
    @editorSelect.addItemsWithTitles(['TextMate', 'Netbeans'])
    @editorSelect.selectItemWithTitle($app.default_from_key(:editor, 'TextMate'))
    editorCheckBoxClicked(nil)
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
    @panel.title = "#{title} Preferences"
    NSAnimationContext.beginGrouping
      @panel.contentView.animator.replaceSubview_with(previousView, view)
      @panel.animator.setFrame_display newFrame, true
    NSAnimationContext.endGrouping    
  end
  
  def viewForTag(tag)
    case tag
      when 0: [@generalsPrefsView, "General"]
      when 1: [@binariesPrefsView,  "Executables"]
      when 2: [@editorPrefsView, "Editor"]
      when 3: [@updatePrefsView, "Software Update"]
    end
  end
  
  def newFrameForNewContentView(view)
    newFrameRect = @panel.frameRectForContentRect(view.frame)
    oldFrameRect = @panel.frame
    newSize = newFrameRect.size
    oldSize = oldFrameRect.size
    frame = @panel.frame
    frame.size = newSize
    frame.origin.y = frame.origin.y - (newSize.height - oldSize.height)
    frame
  end  
  
  def editorCheckBoxClicked(sender)
    $app.default_for_key(:editor_integration, @editorCheckBox.state)
    enabled = @editorCheckBox.state != 0
    @editorSelect.enabled = enabled
    @editorBinPath.enabled = enabled
  end
  
  def editorSelectChanged(sender)
    $app.default_for_key(:editor, @editorSelect.selectedItem.title)
  end
  
  def windowWillClose(notification)
    validatePreferences
  end
  
  def validatePreferences
    controlTextDidEndEditing(nil)
    $app.alert("Cannot find your RSpec executable.", "Please check 'Preferences > Executables > RSpec'.") unless File.exist?(@specBinPath.stringValue)
    $app.alert("Cannot find your Ruby executable.", "Please check 'Preferences > Executables > Ruby'.") unless File.exist?(@rubyBinPath.stringValue)        
    if @editorCheckBox.state != 0 && !File.exist?(@editorBinPath.stringValue)
      $app.alert("Cannot find your #{@editorSelect.selectedItem.title} executable.", "Please check 'Preferences > Editor > Executable'.")
    end
  end  
end