require 'osx/cocoa'

class GrowlController < OSX::NSObject
  MESSAGE_KIND = 'message'
  CLICKED_KIND = 'clicked'

  attr_accessor :growl

  def initialize
    @growl = GrowlNotifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])
    
    Notification.subscribe self, :spec_run_example_failed =>  :specRunFinishedSingleSpec
    Notification.subscribe self, :spec_run_dump_summary   =>  :specRunFinishedWithSummaryDump    
    Notification.subscribe self, :error                   =>  :errorPosted    
  end
  
  def specRunFinishedSingleSpec(notification)    
    return if Defaults.summarize_growl_output?
    return if $app.failed_spec_count >= 11

    spec = notification.userInfo.first
    unless SpecRunner.current_job.hide_growl_messages_for_failed_examples && spec.state == :failed      
      if $app.failed_spec_count == 10
        @growl.notify(MESSAGE_KIND, "Too many failed examples", "RSpactor won't show more than 20 failed example reports at once.", nil, false, 999, imageForGrowl(:warning))
      else
        @growl.notify(MESSAGE_KIND, "#{spec.name}", spec.message, nil, false, 0, imageForGrowl)
      end
    end
  end
  
  def specRunFinishedWithSummaryDump(notification)    
    duration, example_count, failure_count, pending_count = notification.userInfo
    unless SpecRunner.current_job.hide_growl_messages_for_failed_examples && failure_count != 0
      message = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending\nTook: #{("%0.2f" % duration).to_f} seconds"
      status_image = imageForGrowl((failure_count == 0) ? :pass : :failure)    
      @growl.notify(MESSAGE_KIND, 'RSpactor Results', message, nil, false, 0, status_image)    
    end
  end

  def errorPosted(notification)
    title = 'SpecRunner aborted.'
    message = "Please have a look at the 'Output' for more information."
    @growl.notify(MESSAGE_KIND, title, message, nil, false, 0, imageForGrowl(:warning))    
  end
  
  
  private
  
    def imageForGrowl(kind = :failure)
      OSX::NSImage.new.initByReferencingFile(File.join(File.dirname(__FILE__), "#{kind.to_s}_128.png"))      
    end
end
