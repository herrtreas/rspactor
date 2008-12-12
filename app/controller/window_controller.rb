require 'osx/cocoa'

class WindowController < OSX::NSWindowController
  ib_outlet :pathTextField, :statusBar, :statusLabel, :statusBarPassedCount, :statusBarPendingCount, :statusBarFailedCount
  ib_outlet :toolbar_item_run, :toolbar_item_path
  ib_outlet :menu_examples_run, :menu_examples_stop
  ib_action :runSpecs

  ib_action :goToPathTextField do |sender|
    focusPathTextField
  end

  ib_action :stopSpecRun do |sender|
    SpecRunner.terminate_current_task
  end
  
  def awakeFromNib
    initAndSetAutomaticPositionAndSizeStoring
    @growlController = GrowlController.alloc.init
    @pathTextField.stringValue = $app.default_from_key(:spec_run_path)
    focusPathTextField    
    hook_events
  end
  
  def focusPathTextField
    self.window.makeFirstResponder(@pathTextField)    
  end
  
  def runSpecs(sender)
    return if SpecRunner.command_running?
    return unless valid_bin_paths?
    path = File.expand_path(@pathTextField.stringValue)
    if !@pathTextField.stringValue.empty? && path_is_valid?(path)
      path = File.expand_path(@pathTextField.stringValue)
      savePathToUserDefaults(@pathTextField.stringValue)
      SpecRunner.run_job(ExampleRunnerJob.new(:root => path.to_s))
    else
      return false
    end
  end
  
  def showExampleRunPanels
    @statusBar.hidden = false
    @toolbar_item_path.enabled = false
    @menu_examples_run.enabled = false
    @menu_examples_stop.enabled = true
    @statusBarPassedCount.hidden = true
    @statusBarPendingCount.hidden = true
    @statusBarFailedCount.hidden = true
    @toolbar_item_run.image = OSX::NSImage.imageNamed('stop')
    @toolbar_item_run.label = 'Stop'
    @toolbar_item_run.action = 'stopSpecRun:'
  end
  
  def showSilentPanels
    @statusBar.hidden = true
    @toolbar_item_path.enabled = true
    @menu_examples_run.enabled = true
    @menu_examples_stop.enabled = false
    @statusBarPassedCount.hidden = false    
    @statusBarPendingCount.hidden = false    
    @statusBarFailedCount.hidden = false    
    @toolbar_item_run.image = NSImage.imageNamed('play')
    @toolbar_item_run.label = 'Run'    
    @toolbar_item_run.action = 'runSpecs:'    
  end
  
  def specRunPreparation(notification)
    showExampleRunPanels
    @statusLabel.stringValue = "Loading RSpec environment.."
    @statusBar.indeterminate = true
    @statusBar.startAnimation(self)    
  end
  
  def specRunStarted(notification)
    @statusBar.indeterminate = false
    @statusBar.minValue = 1.0    
    @statusBar.doubleValue = 1.0
    @statusBar.maxValue = notification.userInfo.first
  end
  
  def specServerLoading(notification)
    @statusLabel.stringValue = "Loading Spec Server.."
  end
  
  def specRunFinished(notification)
    showSilentPanels
  end
  
  def specRunFinishedSingleSpec(notification)
    begin
      @statusBar.incrementBy 1.0
      @statusLabel.stringValue = "#{notification.userInfo.first}"
    rescue => e
      $LOG.error "Error in specRunFinishedSingleSpec: #{e}"
    end
  end
  
  def savePathToUserDefaults(path)
    $app.default_for_key(:spec_run_path, path)
  end
  
  def relocateDirectoryAndRunSpecs(notification)
    $LOG.debug "relocating and running in.. #{notification.userInfo.first}"
    @pathTextField.stringValue = notification.userInfo.first
    runSpecs(nil)
  end
  
  def updateStatusBarExampleStateCounts(notification)
    duration, example_count, failure_count, pending_count = notification.userInfo    
    total_example_count = example_count.to_i - failure_count.to_i - pending_count.to_i
    @statusLabel.stringValue = "Finished running #{total_example_count} #{total_example_count == 1 ? 'example' : 'examples'} in #{("%0.2f" % duration).to_f} seconds."
    @statusBarPassedCount.title = total_example_count
    @statusBarPendingCount.title = pending_count
    @statusBarFailedCount.title = failure_count
  end
  
  def controlTextDidChange(notification)
    @pathTextField.stringValue = @pathTextField.stringValue.chomp
  end  
  
  def initAndSetAutomaticPositionAndSizeStoring
    shouldCascadeWindows = false
    self.window.frameUsingName = 'rspactor_main_window'
    self.window.frameAutosaveName = 'rspactor_main_window'
  end
  
  def resurrectWindow(notification)
    self.window.makeKeyAndOrderFront(self)
  end
  
  def path_is_valid?(path)
    if File.exist?(path)
      return true
    else
      $app.alert("The path you have entered doesn't exist.", "Please check your input and try again.")
      return false
    end    
  end
  
  def valid_bin_paths?
    unless File.exist?($app.default_from_key(:spec_bin_path, ''))
      $app.alert("Cannot find your RSpec executable.", "Please check 'Preferences > Executables > RSpec'.")
      return false
    end
    unless File.exist?($app.default_from_key(:ruby_bin_path, ''))
      $app.alert("Cannot find your Ruby executable.", "Please check 'Preferences > Executables > Ruby'.")
      return false
    end
    if $app.default_from_key(:editor_integration) == '1' && !File.exist?($app.default_from_key(:editor_bin_path, ''))
      $app.alert("Cannot find your editor executable.", "Please check 'Preferences > Editor > Executable'.")
      return false
    end
    true
  end

  def hook_events
    receive :spec_run_invoked,          :specRunPreparation    
    receive :spec_run_start,            :specRunStarted
    receive :spec_run_close,            :specRunFinished
    receive :spec_run_example_passed,   :specRunFinishedSingleSpec
    receive :spec_run_example_pending,  :specRunFinishedSingleSpec
    receive :spec_run_example_failed,   :specRunFinishedSingleSpec
    receive :spec_run_dump_summary,     :updateStatusBarExampleStateCounts    
    receive :spec_server_loading,       :specServerLoading
    receive :error,                     :specRunFinished
    receive :relocate_and_run,          :relocateDirectoryAndRunSpecs
    receive :application_resurrected,   :resurrectWindow    
  end    
end
