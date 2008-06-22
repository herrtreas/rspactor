require 'osx/cocoa'

class AppController < OSX::NSObject
  
  def initialize
    $spec_list = SpecList.new
    $app = self
  end
  
  def applicationDidFinishLaunching(notification)
    Service.init
    receive :spec_run_start,                  :spec_run_has_started
    receive :spec_run_example_passed,         :spec_run_processed
    receive :spec_run_example_pending,        :spec_run_processed
    receive :spec_run_example_failed,         :spec_run_processed
    receive :spec_run_close,                  :specRunFinished
    receive :NSTaskDidTerminateNotification,  :taskHasFinished   
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
    if spec.state == :failed && @first_failed_notification_posted.nil?
      @first_failed_notification_posted = true
      post_notification :first_failed_spec, spec
    end
  end
  
  def specRunFinished(notification)
    SpecRunner.commandHasFinished!
  end
  
  def taskHasFinished(notification)
    if notification.object.terminationStatus != 0
      data = notification.object.standardError.fileHandleForReading.availableData
      text = NSString.alloc.initWithData_encoding(data, NSASCIIStringEncoding)
      unless text.empty?
        $LOG.debug "Task failed!: #{text}"
        post_error(text)
      end
    end    
    Listener.init($map.root)    
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
  
  def post_error(message)
    $LOG.error message
    post_notification(:error, message)
    SpecRunner.commandHasFinished!    
  end
  
end