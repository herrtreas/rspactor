require 'osx/cocoa'
require 'Growl'

class WindowController < OSX::NSWindowController
  include OSX
  include Callback
  
  attr_accessor :failed_spec_table, :preferences_visible

  ib_outlet :specPath, :detailView, :specRunButton, :specRunningIndicator
  ib_action :runSpecs
  ib_action :showPreferences
  
  def init
    @growl = Growl::Notifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])    
    @pref = false
    super_init    
  end
    
  def awakeFromNib
    @failed_spec_table = SpecTable.alloc.init(self)    
    $coreInterop.start_listen(@specPath.stringValue)    
    setCallbacks
  end
  
  def selectSpecUnlessSelected
    puts "Halo: #{failed_spec_table.selectedRow}"
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
  
  def stop_spec_run
    @specRunButton.Enabled = true
    @specRunningIndicator.stopAnimation(self)     
    $coreInterop.start_listen(@specPath.stringValue)    
  end
  
  def showPreferences(sender)
    $pref_controller.show
  end
end
