require 'osx/cocoa'

class WindowController < OSX::NSWindowController
  ib_outlet :pathTextField, :runButton, :statusBar, :statusLabel
  ib_action :runSpecs
  
  def awakeFromNib
    initAndSetAutomaticPositionAndSizeStoring
    @growlController = GrowlController.new
    @pathTextField.stringValue = $app.default_from_key(:spec_run_path)
    receive :spec_run_invoked,          :specRunPreparation    
    receive :spec_run_start,            :specRunStarted
    receive :spec_run_close,            :specRunFinished
    receive :spec_run_example_passed,   :specRunFinishedSingleSpec
    receive :spec_run_example_pending,  :specRunFinishedSingleSpec
    receive :spec_run_example_failed,   :specRunFinishedSingleSpec
    receive :error,                     :specRunFinished
    receive :relocate_and_run,          :relocateDirectoryAndRunSpecs
  end
  
  def runSpecs(sender)
    return if SpecRunner.command_running?
    path = @pathTextField.stringValue
    return false if path.empty? || !File.exist?(path)
    specRunPreparation(nil)
    SpecRunner.run_in_path(path)
  end
  
  def showStatusPanel
    @runButton.enabled = false
    @pathTextField.hidden = true
    @statusBar.hidden = false
    @statusLabel.hidden = false
  end
  
  def showInputPanel
    @runButton.enabled = true
    @pathTextField.hidden = false
    @statusBar.hidden = true
    @statusLabel.hidden = true
  end
  
  def specRunPreparation(notification)
    showStatusPanel
    @statusLabel.stringValue = "Loading environment.. ( #{@pathTextField.stringValue} )"
    @statusBar.indeterminate = true
    @statusBar.startAnimation(self)    
  end
  
  def specRunStarted(notification)
    @statusBar.indeterminate = false
    @statusBar.minValue = 1.0    
    @statusBar.doubleValue = 1.0
    @statusBar.maxValue = notification.userInfo.first
  end
  
  def specRunFinished(notification)
    showInputPanel
  end
  
  def specRunFinishedSingleSpec(notification)
    @statusBar.incrementBy 1.0
    @statusLabel.stringValue = "Running #{$spec_list.processed_spec_count}...#{$spec_list.total_spec_count}"
  end
  
  def controlTextDidChange(notification)
    $app.default_for_key(:spec_run_path, notification.object.stringValue)
  end
  
  def relocateDirectoryAndRunSpecs(notification)
    $LOG.debug "relocating and running in.. #{notification.userInfo.first}"
    @pathTextField.stringValue = notification.userInfo.first
    runSpecs(nil)
  end
  
  def initAndSetAutomaticPositionAndSizeStoring
    shouldCascadeWindows = false
    self.window.frameUsingName = 'rspactor_main_window'
    self.window.frameAutosaveName = 'rspactor_main_window'
  end
  
end
