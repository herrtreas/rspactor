require 'osx/cocoa'

class GrowlController < OSX::NSObject
  MESSAGE_KIND = 'message'
  CLICKED_KIND = 'clicked'

  attr_accessor :growl

  def initialize
    @growl = GrowlNotifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])
    
    receive :spec_run_example_failed,   :specRunFinishedSingleSpec
    receive :spec_run_dump_summary,     :specRunFinishedWithSummaryDump    
    receive :error,                     :errorPosted    
  end
  
  def specRunFinishedSingleSpec(notification)
    spec = notification.userInfo.first
    @growl.notify(MESSAGE_KIND, "#{spec.name}", spec.message, nil, false, 0, imageForGrowl)
  end
  
  def specRunFinishedWithSummaryDump(notification)
    duration, example_count, failure_count, pending_count = notification.userInfo
    message = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending\nTook: #{duration.to_f.round} seconds"
    status_image = imageForGrowl((failure_count == 0) ? :pass : :failure)    
    @growl.notify(MESSAGE_KIND, 'RSpactor Results', message, nil, false, 0, status_image)    
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
