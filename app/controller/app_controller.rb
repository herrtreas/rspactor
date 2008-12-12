require 'osx/cocoa'

class AppController < OSX::NSObject
  
  attr_accessor :example_start_time
  attr_accessor :processed_spec_count, :total_spec_count, :failed_spec_count
  attr_accessor :root
  attr_accessor :run_failed_afterwards
  
  
  def initialize
    $app = self
    $raw_output = []
    self.processed_spec_count = 0
    self.total_spec_count = 0
    self.failed_spec_count = 0
    ExampleFiles.init
    SpecRunner.init
  end
  
  def applicationDidFinishLaunching(notification)
    Service.init
    receive :spec_run_start,                          :spec_run_has_started
    receive :example_run_example_started,             :exampleRunExampleStarted
    receive :spec_run_example_passed,                 :spec_run_processed
    receive :spec_run_example_pending,                :spec_run_processed
    receive :spec_run_example_failed,                 :spec_run_processed
    receive :spec_run_close,                          :specRunFinished
    receive :spec_attached_to_file,                   :specAttachedToFile
    receive :NSTaskDidTerminateNotification,          :taskHasFinished
    receive :NSFileHandleReadCompletionNotification,  :pipeContentAvailable
    receive :observation_requested,                   :add_request_to_listeners_observation_list    
    receive :example_run_global_start,                :setupActiveBadge
    receive :spec_server_ready,                       :launchSpecRunnerTask
    receive :spec_server_failed,                      :specServerFailed
  end
  
  def applicationShouldHandleReopen_hasVisibleWindows(application, has_open_windows)
    post_notification :application_resurrected
  end

  def applicationWillTerminate(notification)
    $LOG.debug "Exiting.."
    SpecServer.cleanup
  end
  
  def launchSpecRunnerTask(notification)
    # TODO: Move the event hook into SpecRunner
    SpecRunner.launch_current_task
  end
  
  def spec_run_has_started(notification)
    self.processed_spec_count = 0
    self.failed_spec_count = 0
    self.total_spec_count = notification.userInfo.first
    self.run_failed_afterwards = false
    @first_failed_notification_posted = nil
    ExampleFiles.tainting_required_on_all_files!
  end
  
  def exampleRunExampleStarted(notification)
    @example_start_time = Time.now
  end
  
  def spec_run_processed(notification)
    example_end_time = Time.now
    self.processed_spec_count += 1
    unless notification.userInfo.first.backtrace.empty?
      spec = notification.userInfo.first
      self.failed_spec_count += 1 if spec.state == :failed
      spec.run_time = example_end_time - @example_start_time
      ExampleFiles.add_spec(spec)
      post_notification :spec_run_processed, spec
      if spec.state == :failed && @first_failed_notification_posted.nil?
        @first_failed_notification_posted = true
        post_notification :first_failed_spec, spec
      end
    end
  end
  
  def specAttachedToFile(notification)
    return unless $app.default_from_key(:generals_rerun_failed_specs, '1') == '1'
    return unless notification.userInfo.first.file_object
    return unless notification.userInfo.first.previous_state
    
    spec = notification.userInfo.first
    if spec.previous_state == :failed && spec.state == :passed
      @files_with_passed_specs ||= []
      @files_with_passed_specs << spec.file_object.path if spec.file_object
      self.run_failed_afterwards = true
    end      
  end
  
  def specRunFinished(notification)
    @_spec_run_normally_completed = true
  end
  
  def taskHasFinished(notification)        
   begin     
      return unless notification.object == SpecRunner.task

      $LOG.debug "Task has finished.."
      if SpecRunner.commandAbortedByHand?
        $LOG.debug "Task aborted by hand.."
        post_notification(:spec_run_close)
      elsif !@_spec_run_normally_completed && notification.object.terminationStatus != 0 && !SpecRunner.commandFinished?
        $LOG.debug "Task aborted.."
        post_notification(:error)        
      else
        setupBadgeWithFailedSpecCount(ExampleFiles.total_failed_spec_count)      
      end

      @_spec_run_normally_completed = nil

      $output_pipe_handle.closeFile
      $error_pipe_handle.closeFile

      specs = ExampleFiles.clear_tainted_specs_on_all_files!.flatten.compact.select { |spec| spec && spec.file_object }      
      post_notification :webview_reload_required_for_specs, specs
      
      SpecRunner.commandHasFinished!
      post_notification :example_run_global_complete
      Listener.init($app.root)        
      
      run_failed_files_afterwards_or_listen
    rescue => e
     $LOG.error "taskHasFinished: #{e}"
    end
  end
  
  def specServerFailed(notification)
    alert('Could not load the spec_server.', 'Is another spec_server already running?')
  end
  
  def run_failed_files_afterwards_or_listen
    if self.run_failed_afterwards && self.run_failed_afterwards == true
      failed_files_paths = ExampleFiles.failed.collect { |ef| ef.path }
      if @files_with_passed_specs && !@files_with_passed_specs.empty?
        failed_files_paths.delete_if { |path| @files_with_passed_specs.include?(path) }
        @files_with_passed_specs = nil
      end
      if failed_files_paths.empty?
        return false
      else
        failed_files_job = ExampleRunnerJob.new(:paths => failed_files_paths)
        failed_files_job.hide_growl_messages_for_failed_examples = true
        SpecRunner.run_job(failed_files_job)
        return true
      end
    else
      false
    end
  end
  
  def center
    OSX::NSNotificationCenter.defaultCenter
  end
  
  def defaults
    OSX::NSUserDefaults.standardUserDefaults
  end
  
  def default_from_key(key, rescue_value = '')
    defaults.stringForKey(key) || rescue_value
  end
  
  def default_for_key(key, value)
    defaults.setObject_forKey(value, key.to_s)
  end
  
  def post_notification(name, *args)
    center.postNotificationName_object_userInfo(name.to_s, self, args)    
  end
  
  def alert(message, information)
    alert = NSAlert.alloc.init
    alert.alertStyle = OSX::NSCriticalAlertStyle
    alert.messageText = message
    alert.informativeText = information
    alert.runModal
  end  
  
  def pipeContentAvailable(notification)
    if notification.object == $output_pipe_handle || notification.object == $error_pipe_handle
      raw_output = NSString.alloc.initWithData_encoding(notification.userInfo[OSX::NSFileHandleNotificationDataItem], NSASCIIStringEncoding)
      unless raw_output.empty?
        $raw_output[0][1] << raw_output
        $output_pipe_handle.readInBackgroundAndNotify
        $error_pipe_handle.readInBackgroundAndNotify
      end
    else
      SpecServer.pipeContentAvailable(notification)
    end
  end
  
  def add_request_to_listeners_observation_list(notification)
    Listener.add_request_to_observation_list(notification)
  end

  def setupDefaultBadge
    NSApp.setApplicationIconImage(NSImage.imageNamed('APPL.icns'))
  end
  
  def setupActiveBadge(notification)
    drawDockBadgeWithMessage('play', NSString.stringWithFormat('%s', ''))
  end
  
  def setupBadgeWithFailedSpecCount(count)
    if count == 0
      setupDefaultBadge
    else
      failed_spec_count = NSString.stringWithFormat('%i', count)
      drawDockBadgeWithMessage('badge.png', failed_spec_count)
    end
  end  
  
  def drawDockBadgeWithMessage(image_name, message)
    # Gladly translated from http://th30z.netsons.org/2008/10/cocoa-notification-badge/ to Ruby
    # Thanks to Matteo Bertozzi for the article..
  
    icon = NSImage.imageNamed('APPL.icns')
    icon_buffer = icon.copy
    size = icon.size

    # Create attributes for drawing the count.
    font = NSFont.fontWithName_size('Helvetica-Bold', 28)
    color = NSColor.whiteColor
    attributes = OSX::NSDictionary.alloc.initWithObjectsAndKeys(font, OSX::NSFontAttributeName, color, OSX::NSForegroundColorAttributeName, nil)
    num_size = message.sizeWithAttributes(attributes)

    # Create a red circle in the icon large enough to hold the count.
    icon_buffer.lockFocus
    icon.drawAtPoint_fromRect_operation_fraction(NSMakePoint(0, 0), NSMakeRect(0, 0, size.width, size.height), OSX::NSCompositeSourceOver, 1.0)    
    max = (num_size.width > num_size.height) ? num_size.width : num_size.height
    max += 24
    circle_rect = NSMakeRect(size.width - max, size.height - max, max, max);

    # Draw the star image and scale it so the unread count will fit inside.
    star_image = NSImage.imageNamed(image_name)
    star_image.scalesWhenResized = true
    star_image.setSize(circle_rect.size)
    star_image.compositeToPoint_operation(circle_rect.origin, OSX::NSCompositeSourceOver)

    # Draw the count in the red circle
    point = NSMakePoint(NSMidX(circle_rect) - num_size.width / 2 + 2, NSMidY(circle_rect) - num_size.height / 2 + 2);
    message.drawAtPoint_withAttributes(point, attributes)
 
    # Now set the new app icon and clean up.
    icon_buffer.unlockFocus
    NSApp.setApplicationIconImage(icon_buffer)
    icon_buffer.release
    attributes.release
  end
end