module Callback
  MESSAGE_KIND = 'message'
  CLICKED_KIND = 'clicked'
  
  def setCallbacks
    
    # Return with true to signal availability
    $coreInterop.ping = lambda { true }
    
    $coreInterop.command_error = lambda do |error_message|
      setSystemMenuIcon(:error)
      stop_spec_run
      $details.setError(error_message.join("\n"))
      title, message = 'Error loading spec environment!', error_message[0...2].join("\n")
      @growl.notify(MESSAGE_KIND, title, message, 'clickcontext', false, 0, growlImage(:error))
    end
    
    # Change location (invoke from command line)
    $coreInterop.change_location = lambda do |location|
      @defaults.setObject_forKey(location, 'last_spec_path')                
      @specPath.stringValue = location
      runSpecs(nil)
    end

    # Spec running has started
    $coreInterop.spec_run_start = lambda do |example_count|
      setSystemMenuIcon # set to ok
      
      $all_specs, $failed_specs, $pending_specs = [], [], []
      @all_spec_table.reload!
      @pending_spec_table.reload!
      @failed_spec_table.reload!
      
      $details.clear

      @specRunningIndicator.setIndeterminate(false)
      @specRunningIndicator.startAnimation(self)      
      @specRunningIndicator.setMinValue(1.0)      
      @specRunningIndicator.setDoubleValue(1.0)      
      @specRunningIndicator.setMaxValue(example_count)

#      @growl.notify(MESSAGE_KIND, "Running #{example_count} specs", '', 'clickcontext', false, 0, growlImage(:ok))      
    end

    # An example has passed
    $coreInterop.spec_run_example_passed = lambda do |spec|
      @specRunningIndicator.incrementBy(1.0)
      $all_specs << spec
      @all_spec_table.reload!
    end

    # An example is pending
    $coreInterop.spec_run_example_pending = lambda do |spec|
      @specRunningIndicator.incrementBy(1.0)
      $all_specs << spec
      @all_spec_table.reload!
      $pending_specs << spec
      @pending_spec_table.reload!
    end

    # Receive failed specs
    $coreInterop.spec_run_example_failed = lambda do |spec|
      setSystemMenuIcon(:failure)
      
      @specRunningIndicator.incrementBy(1.0)      
      $failed_specs << spec
      @failed_spec_table.reload!
      @all_spec_table.reload!
      
      # error_message = [
      #   spec.error_header,
      #   "\n#{spec.file}:#{spec.line}", 
      #   spec.message
      # ].join("\n")
      
#      selectSpecUnlessSelected
      @growl.notify(MESSAGE_KIND, "#{spec.name}", spec.message, 'clickcontext', false, 0, growlImage(:failure))      
    end    
    
    # Receive summary dump
    $coreInterop.spec_run_dump_summary = lambda do |duration, example_count, failure_count, pending_count|
      msg = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending\nTook: #{duration} seconds"
      status_image = growlImage((failure_count == 0) ? :pass : :failure)
      @growl.notify(MESSAGE_KIND, 'RSpactor results', msg, 'clickcontext', false, 0, status_image)
    end

    # Stop Spec Runner Progress
    $coreInterop.spec_run_close = lambda do
      stop_spec_run
    end
  end
  
end