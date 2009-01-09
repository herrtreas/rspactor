require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  ib_outlet :panel, :toolbar
  ib_outlet :generalsPrefsView, :binariesPrefsView, :editorPrefsView, :updatePrefsView, :speechPrefsView
  ib_outlet :specBinPath, :rubyBinPath, :editorBinPath
  ib_outlet :rubyBinWarning, :specBinWarning, :editorBinWarning
  ib_outlet :editorSelect, :editorCheckBox
  ib_outlet :generalsRerunSpecsCheckBox, :generalsSummarizeGrowl, :generalsAutoActivateSpecServer
	ib_outlet :speechUseSpeechCheckBox
	ib_outlet :phraseForTestsPass, :phraseForTestsFail, :phraseForTestsPending
	ib_outlet :voiceTestsPassSelect, :voiceTestsFailSelect, :voiceTestsPendingSelect
  
  ib_action :toolbarItemClicked
  ib_action :editorCheckBoxClicked
  ib_action :editorSelectChanged
	ib_action :speechCheckBoxClicked
	ib_action :voiceTestsPassChanged
	ib_action :voiceTestsFailChanged
	ib_action :voiceTestsPendingChanged
  
  
  ib_action :checkBoxClickedToSaveState do |sender|
    case sender.tag
    when 101:
      Defaults.set(:generals_rerun_failed_specs, sender.state)      
    when 102:
      Defaults.set(:generals_summarize_growl_output, sender.state)
    when 103:
      Defaults.set(:generals_auto_activate_spec_server, sender.state)
    end
  end
  
  ib_action :resetHiddenNotices do |sender|
    Defaults.set('hide_welcome_message', '0')    
  end
  
  def initialize
    unless Defaults.get(:spec_bin_path, nil)
      spec_bin_path = `/usr/bin/which spec`.strip.chomp
      Defaults.set(:spec_bin_path, spec_bin_path.chomp.strip) unless spec_bin_path.empty?
    end
    unless Defaults.get(:ruby_bin_path, nil)
      ruby_bin_path = `/usr/bin/which ruby`.strip.chomp
      Defaults.set(:ruby_bin_path, ruby_bin_path.chomp.strip) unless ruby_bin_path.empty?
    end
  end
  
  def awakeFromNib
    set_default_spec_bin_path
    set_default_ruby_bin_path
    set_default_editor_bin_path
    initToolbar
    initGeneralPrefView
    initEditorPrefView
		initSpeechPrefView
    validatePreferences
  end

  def showWindow(sender)
    @panel.makeKeyAndOrderFront(self)
  end
  
  def set_default_spec_bin_path
    @specBinPath.stringValue = Defaults.get(:spec_bin_path, '/usr/bin/spec')
  end
  
  def set_default_ruby_bin_path
    @rubyBinPath.stringValue = Defaults.get(:ruby_bin_path, '/usr/bin/ruby')
  end

  def set_default_editor_bin_path
    @editorBinPath.stringValue = Defaults.get(:editor_bin_path, '/usr/bin/mate')
  end
	  
  def controlTextDidEndEditing(notification)
    setBinPathsFromNotification(notification)
    setSpeechPhrasesFromNotification(notification)
  end
  
  def setBinPathsFromNotification(notification)
    check_path_and_set_default(:spec_bin_path, @specBinPath, @specBinWarning)  if notification.nil? || notification.object.stringValue == @specBinPath.stringValue
    check_path_and_set_default(:ruby_bin_path, @rubyBinPath, @rubyBinWarning)  if notification.nil? || notification.object.stringValue == @rubyBinPath.stringValue
    check_path_and_set_default(:editor_bin_path, @editorBinPath, @editorBinWarning)  if notification.nil? || notification.object.stringValue == @editorBinPath.stringValue
  end

  def setSpeechPhrasesFromNotification(notification)
    Defaults.set(:speech_phrase_tests_pass, @phraseForTestsPass.stringValue.chomp.strip) if notification.nil? || notification.object.stringValue == @phraseForTestsPass.stringValue
    Defaults.set(:speech_phrase_tests_fail, @phraseForTestsFail.stringValue.chomp.strip) if notification.nil? || notification.object.stringValue == @phraseForTestsFail.stringValue
    Defaults.set(:speech_phrase_tests_pending, @phraseForTestsPending.stringValue.chomp.strip) if notification.nil? || notification.object.stringValue == @phraseForTestsPending.stringValue
  end
  
  def check_path_and_set_default(key, path_object, warning_object)
    path_object.stringValue = path_object.stringValue.chomp.strip
    path = path_object.stringValue
    Defaults.set(key, path)
    if File.exist?(path)
      warning_object.hidden = true
    else
      warning_object.hidden = false
      warning_object.toolTip = "That path doesn't exist."
    end
  end
	  
  def initGeneralPrefView
    @generalsRerunSpecsCheckBox.state = Defaults.get(:generals_rerun_failed_specs, '1')
    @generalsSummarizeGrowl.state = Defaults.get(:generals_summarize_growl_output, '0')
    @generalsAutoActivateSpecServer.state = Defaults.get(:generals_auto_activate_spec_server, '1')
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
    @editorCheckBox.state = Defaults.get(:editor_integration, '0')
    @editorSelect.removeAllItems
    @editorSelect.addItemsWithTitles(['TextMate', 'Netbeans', 'MacVim'])
    @editorSelect.selectItemWithTitle(Defaults.get(:editor, 'TextMate'))
    editorCheckBoxClicked(nil)
  end
	
	def initSpeechPrefView
    @speechUseSpeechCheckBox.state = Defaults.get(:speech_use_speech, '0')
		@phraseForTestsPass.stringValue = Defaults.get(:speech_phrase_tests_pass, 'All examples passed.')
		@phraseForTestsFail.stringValue = Defaults.get(:speech_phrase_tests_fail, 'Examples failed!')
		@phraseForTestsPending.stringValue = Defaults.get(:speech_phrase_tests_pending, 'Examples passed, some pending.')
		
		voices = NSSpeechSynthesizer.availableVoices.collect { |v| v.split('.').last }
		default_voice = NSSpeechSynthesizer.defaultVoice.split('.').last

		@voiceTestsPassSelect.removeAllItems
		@voiceTestsPassSelect.addItemsWithTitles(voices)
    @voiceTestsPassSelect.selectItemWithTitle(Defaults.get(:speech_voice_tests_pass, default_voice))
		@voiceTestsFailSelect.removeAllItems
		@voiceTestsFailSelect.addItemsWithTitles(voices)
    @voiceTestsFailSelect.selectItemWithTitle(Defaults.get(:speech_voice_tests_fail, default_voice))
		@voiceTestsPendingSelect.removeAllItems
		@voiceTestsPendingSelect.addItemsWithTitles(voices)
    @voiceTestsPendingSelect.selectItemWithTitle(Defaults.get(:speech_voice_tests_pending, default_voice))
		
		speechCheckBoxClicked(nil)
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
      when 4: [@speechPrefsView, "Speech"]
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
    Defaults.set(:editor_integration, @editorCheckBox.state)
    enabled = @editorCheckBox.state != 0
    @editorSelect.enabled = enabled
    @editorBinPath.enabled = enabled
  end
  
  def editorSelectChanged(sender)
    Defaults.set(:editor, @editorSelect.selectedItem.title)
  end
	
	def speechCheckBoxClicked(sender)
		Defaults.set(:speech_use_speech, @speechUseSpeechCheckBox.state)
    enabled = @speechUseSpeechCheckBox.state != 0
		@phraseForTestsPass.enabled = enabled
		@phraseForTestsFail.enabled = enabled
		@phraseForTestsPending.enabled = enabled
		@voiceTestsPassSelect.enabled = enabled
		@voiceTestsFailSelect.enabled = enabled
		@voiceTestsPendingSelect.enabled = enabled
	end
	
	def voiceTestsPassChanged(sender)
    Defaults.set(:speech_voice_tests_pass, @voiceTestsPassSelect.selectedItem.title)
	end
	
	def voiceTestsFailChanged(sender)
    Defaults.set(:speech_voice_tests_fail, @voiceTestsFailSelect.selectedItem.title)
	end
	
	def voiceTestsPendingChanged(sender)
    Defaults.set(:speech_voice_tests_pending, @voiceTestsPendingSelect.selectedItem.title)
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