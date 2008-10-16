require 'osx/cocoa'

class AppController < OSX::NSObject
  
  def initialize
    $spec_list = SpecList.new
    $app = self
    $raw_output = []
  end
  
  def applicationDidFinishLaunching(notification)
    Service.init
    receive :spec_run_start,                          :spec_run_has_started
    receive :spec_run_example_passed,                 :spec_run_processed
    receive :spec_run_example_pending,                :spec_run_processed
    receive :spec_run_example_failed,                 :spec_run_processed
    receive :spec_run_close,                          :specRunFinished
    receive :NSTaskDidTerminateNotification,          :taskHasFinished
    receive :NSFileHandleReadCompletionNotification,  :pipeContentAvailable
  end
  
  def applicationShouldHandleReopen_hasVisibleWindows(application, has_open_windows)
    post_notification :application_resurrected
  end
  
  def spec_run_has_started(notification)
    $LOG.debug "Spec run started.."
    $spec_list.clear_run_stats
    $spec_list.total_spec_count = notification.userInfo.first
    @first_failed_notification_posted = nil
  end
  
  def spec_run_processed(notification)
    spec = notification.userInfo.first
    $spec_list << spec  
    $spec_list.processed_spec_count += 1
    post_notification :spec_run_processed, spec
    if spec.state == :failed && @first_failed_notification_posted.nil?
      @first_failed_notification_posted = true
      post_notification :first_failed_spec, spec
    end
  end
  
  def specRunFinished(notification)    
    setupBadgeWithFailedSpecCount($spec_list.filter_by(:failed).size)    
    SpecRunner.commandHasFinished!
  end
  
  def taskHasFinished(notification)
    begin     
      $LOG.debug "Task has finished.."    
      if notification.object.terminationStatus != 0 && !SpecRunner.commandFinished?
        $LOG.debug "Task aborted.."
        postTerminationWithFailure
      end            

      $output_pipe_handle.closeFile
      $error_pipe_handle.closeFile      
      Listener.init($map.root) if $map
    rescue; end
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
  
  def postTerminationWithFailure
    post_notification(:error)
    SpecRunner.commandHasFinished!    
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