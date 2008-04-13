require 'osx/cocoa'
require 'Growl'

class WindowController < OSX::NSWindowController
  include OSX
  
  MESSAGE_KIND = 'message'
  CLICKED_KIND = 'clicked'

  attr_accessor :failed_spec_table

  ib_outlet :specPath, :detailView, :specRunButton, :specRunningIndicator
  ib_action :runSpecs
  
  def init
    @growl = Growl::Notifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])    
    super_init
  end
    
  def awakeFromNib
    @failed_spec_table = SpecTable.alloc.init(self)    
    setCallbacks
    $coreInterop.start_listen(@specPath.stringValue)    
  end
  
  def updateDetailView(content)
    @detailView.textStorage.mutableString.setString(content)
  end

  def runSpecs(sender)
    @specRunningIndicator.setIndeterminate(true)    
    @specRunningIndicator.startAnimation(self)      
    @specRunButton.Enabled = false
    $failed_specs.clear
    $coreInterop.run_specs_in_path(@specPath.stringValue)
    @failed_spec_table.clearSelection
  end
  
  def setCallbacks

    $coreInterop.change_location = lambda do |location|
      @specPath.stringValue = location
      runSpecs(nil)
    end

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
    
    $coreInterop.spec_run_example_passed = lambda do
      @specRunningIndicator.incrementBy(1.0)
    end

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
    
    $coreInterop.spec_run_dump_summary = lambda do |duration, example_count, failure_count, pending_count|
      msg = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending\nTook: #{duration} seconds"
      @growl.notify(MESSAGE_KIND, 'RSpactor results', msg, 'clickcontext', false)      
    end
    
    # Stop Spec Runner Progress
    $coreInterop.spec_run_close = lambda do
      @specRunButton.Enabled = true
      @specRunningIndicator.stopAnimation(self)     
      $coreInterop.start_listen(@specPath.stringValue)
    end
  end
  
end
