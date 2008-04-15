module Callback
  MESSAGE_KIND = 'message'
  CLICKED_KIND = 'clicked'
  
  def setCallbacks
    
    # Return with true to signal availability
    $coreInterop.ping = lambda { true }
    
    $coreInterop.command_error = lambda do |error_message|
      stop_spec_run
      updateDetailView(error_message.join("\n"))
      @growl.notify(MESSAGE_KIND, "Error loading spec environment!", error_message[0...2].join("\n"), 'clickcontext', false)
    end
    
    # Change location (invoke from command line)
    $coreInterop.change_location = lambda do |location|
      @specPath.stringValue = location
      runSpecs(nil)
    end

    # Spec running has started
    $coreInterop.spec_run_start = lambda do |example_count|
      $failed_specs = []
      updateDetailView('')
      @failed_spec_table.reload!

      @specRunningIndicator.setIndeterminate(false)
      @specRunningIndicator.startAnimation(self)      
      @specRunningIndicator.setMinValue(1.0)      
      @specRunningIndicator.setDoubleValue(1.0)      
      @specRunningIndicator.setMaxValue(example_count)

      @growl.notify(MESSAGE_KIND, "Running #{example_count} specs", '', 'clickcontext', false)      
    end

    # An example has passed
    $coreInterop.spec_run_example_passed = lambda do
      @specRunningIndicator.incrementBy(1.0)
    end

    # An example is pending
    $coreInterop.spec_run_example_pending = lambda do
      @specRunningIndicator.incrementBy(1.0)
    end

    # Receive failed specs
    $coreInterop.spec_run_example_failed = lambda do |spec|
      @specRunningIndicator.incrementBy(1.0)      
      $failed_specs << spec
      @failed_spec_table.reload!
      @growl.notify(MESSAGE_KIND, "#{spec.name}", spec.error_header, 'clickcontext', false)      
    end    
    
    # Receive summary dump
    $coreInterop.spec_run_dump_summary = lambda do |duration, example_count, failure_count, pending_count|
      msg = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending\nTook: #{duration} seconds"
      @growl.notify(MESSAGE_KIND, 'RSpactor results', msg, 'clickcontext', false)      
    end

    # Stop Spec Runner Progress
    $coreInterop.spec_run_close = lambda do
      stop_spec_run
    end
  end
  
end