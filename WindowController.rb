require 'osx/cocoa'
require 'Growl'

class WindowController < OSX::NSWindowController
  include OSX
  include Callback
  
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
    $coreInterop.start_listen(@specPath.stringValue)    
    setCallbacks
#    setAlert("ERROR")    
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
  
end
