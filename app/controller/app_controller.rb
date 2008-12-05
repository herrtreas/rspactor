require 'osx/cocoa'

class AppController < OSX::NSObject
  
  attr_accessor :root
  attr_accessor :run_failed_afterwards
  
  def initialize
    $app = self
    $raw_output = []
    $processed_spec_count = 0
    $total_spec_count = 0
    ExampleFiles.init
    SpecRunner.init
  end
  
  def applicationDidFinishLaunching(notification)
    Service.init
    receive :spec_run_start,                          :spec_run_has_started
    receive :spec_run_example_passed,                 :spec_run_processed
    receive :spec_run_example_pending,                :spec_run_processed
    receive :spec_run_example_failed,                 :spec_run_processed
    receive :spec_run_close,                          :specRunFinished
    receive :spec_attached_to_file,                   :specAttachedToFile
    receive :NSTaskDidTerminateNotification,          :taskHasFinished
    receive :NSFileHandleReadCompletionNotification,  :pipeContentAvailable
    receive :observation_requested,                   :add_request_to_listeners_observation_list    
  end
  
  def applicationShouldHandleReopen_hasVisibleWindows(application, has_open_windows)
    post_notification :application_resurrected
  end
  
  def spec_run_has_started(notification)
    $processed_spec_count = 0
    $total_spec_count = notification.userInfo.first
    self.run_failed_afterwards = false
    @first_failed_notification_posted = nil
    ExampleFiles.tainting_required_on_all_files!
  end
  
  def spec_run_processed(notification)
    $processed_spec_count += 1
    spec = notification.userInfo.first
    return if spec.backtrace.empty?
    ExampleFiles.add_spec(spec)
    post_notification :spec_run_processed, spec
    if spec.state == :failed && @first_failed_notification_posted.nil?
      @first_failed_notification_posted = true
      post_notification :first_failed_spec, spec
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
      $LOG.debug "Task has finished.."    

      if !@_spec_run_normally_completed && notification.object.terminationStatus != 0 && !SpecRunner.commandFinished?
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
      run_failed_files_afterwards_or_listen
    rescue => e
      $LOG.error "taskHasFinished: #{e}"
    end
  end
  
  def run_failed_files_afterwards_or_listen
    if self.run_failed_afterwards
      failed_files_paths = ExampleFiles.failed.collect { |ef| ef.path }
      if @files_with_passed_specs && !@files_with_passed_specs.empty?
        failed_files_paths.delete_if { |path| @files_with_passed_specs.include?(path) }
        @files_with_passed_specs = nil
      end
      failed_files_job = ExampleRunnerJob.new(:paths => failed_files_paths)
      failed_files_job.hide_growl_messages_for_failed_examples = true
      SpecRunner.run_job(failed_files_job)
    else
      Listener.init($app.root)
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
    raw_output = NSString.alloc.initWithData_encoding(notification.userInfo[OSX::NSFileHandleNotificationDataItem], NSASCIIStringEncoding)
    unless raw_output.empty?
      $raw_output[0][1] << raw_output
      $output_pipe_handle.readInBackgroundAndNotify
      $error_pipe_handle.readInBackgroundAndNotify
    end
  end
  
  def add_request_to_listeners_observation_list(notification)
    Listener.add_request_to_observation_list(notification)
  end
  
  def setupBadgeWithFailedSpecCount(count)
    if count == 0
      NSApp.setApplicationIconImage(NSImage.imageNamed('APPL.icns'))      
    else
      
      # Gladly translated from http://th30z.netsons.org/2008/10/cocoa-notification-badge/ to Ruby
      # Thanks to Matteo Bertozzi for the article..
    
      failed_spec_count = NSString.stringWithFormat('%i', count)    
      icon = NSImage.imageNamed('APPL.icns')
      icon_buffer = icon.copy
      size = icon.size
  
      # Create attributes for drawing the count.
      font = NSFont.fontWithName_size('Helvetica-Bold', 28)
      color = NSColor.whiteColor
      attributes = OSX::NSDictionary.alloc.initWithObjectsAndKeys(font, OSX::NSFontAttributeName, color, OSX::NSForegroundColorAttributeName, nil)
      num_size = failed_spec_count.sizeWithAttributes(attributes)
  
      # Create a red circle in the icon large enough to hold the count.
      icon_buffer.lockFocus
      icon.drawAtPoint_fromRect_operation_fraction(NSMakePoint(0, 0), NSMakeRect(0, 0, size.width, size.height), OSX::NSCompositeSourceOver, 1.0)    
      max = (num_size.width > num_size.height) ? num_size.width : num_size.height
      max += 24
      circle_rect = NSMakeRect(size.width - max, size.height - max, max, max);
  
      # Draw the star image and scale it so the unread count will fit inside.
      star_image = NSImage.imageNamed('badge.png')
      star_image.scalesWhenResized = true
      star_image.setSize(circle_rect.size)
      star_image.compositeToPoint_operation(circle_rect.origin, OSX::NSCompositeSourceOver)
  
      # Draw the count in the red circle
      point = NSMakePoint(NSMidX(circle_rect) - num_size.width / 2 + 2, NSMidY(circle_rect) - num_size.height / 2 + 2);
      failed_spec_count.drawAtPoint_withAttributes(point, attributes)
   
      # Now set the new app icon and clean up.
      icon_buffer.unlockFocus
      NSApp.setApplicationIconImage(icon_buffer)
      icon_buffer.release
      attributes.release
    end
  end  
end