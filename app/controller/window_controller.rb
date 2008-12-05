require 'osx/cocoa'

class WindowController < OSX::NSWindowController
  ib_outlet :pathTextField, :runButton, :statusBar, :statusLabel, :statusBarPassedCount, :statusBarPendingCount, :statusBarFailedCount
  ib_outlet :toolbar_item_run, :toolbar_item_path
  ib_outlet :menu_examples_run, :menu_examples_stop
  ib_action :runSpecs
  
  def awakeFromNib
    initAndSetAutomaticPositionAndSizeStoring
    @growlController = GrowlController.alloc.init
    @pathTextField.stringValue = $app.default_from_key(:spec_run_path)
    self.window.makeFirstResponder(@pathTextField)
    hook_events
  end
  
  def runSpecs(sender)
    return if SpecRunner.command_running?
    return unless valid_bin_paths?
    path = @pathTextField.stringValue
    return false if path.empty? || !File.exist?(path)
    savePathToUserDefaults(path)
    SpecRunner.run_job(ExampleRunnerJob.new(:root => path.to_s))
  end
  
  def showExampleRunPanels
    @statusBar.hidden = false
    @toolbar_item_run.enabled = false
    @toolbar_item_path.enabled = false
    @menu_examples_run.enabled = false
    @menu_examples_stop.enabled = true
    @statusBarPassedCount.hidden = true
    @statusBarPendingCount.hidden = true
    @statusBarFailedCount.hidden = true
  end
  
  def showSilentPanels
    @statusBar.hidden = true
    @toolbar_item_run.enabled = true
    @toolbar_item_path.enabled = true
    @menu_examples_run.enabled = true
    @menu_examples_stop.enabled = false
    @statusBarPassedCount.hidden = false    
    @statusBarPendingCount.hidden = false    
    @statusBarFailedCount.hidden = false    
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
  
  def specRunFinished(notification)
    showSilentPanels
  end
  
  def specRunFinishedSingleSpec(notification)
    begin
      @statusBar.incrementBy 1.0
      @statusLabel.stringValue = "#{notification.userInfo.first}"
    rescue
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
    receive :error,                     :specRunFinished
    receive :relocate_and_run,          :relocateDirectoryAndRunSpecs
    receive :application_resurrected,   :resurrectWindow    
  end    
end
