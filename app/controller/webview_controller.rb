require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  attr_accessor :current_spec_file_view
  
  ib_outlet :view, :tabBar, :toolbar
  
  ib_action :toolbarItemClicked do |sender|
    @toolbar.selectedItemIdentifier = sender.itemIdentifier
    case sender.tag
    when 0:
      loadHtmlView(:dashboard)
    when 1:
      showRawOutputView
    when 2:
      if defined?(@@currently_displayed_file)
        showSpecFileView(@@currently_displayed_file)
      else
        setSpecFileViewLabel(:disabled => true)
        activateHtmlView(:dashboard)
      end
    end    
  end
  
  def awakeFromNib
    receive :fileToWebViewLoadingRequired,              :showSpecFileViewFromTable
    receive :first_failed_spec,                         :showSpecFileViewFromSpec
    receive :spec_run_processed,                        :reloadWebView
    receive :webview_reload_required_for_specs,         :reloadWebViewForSpecs
    
    @view.shouldCloseWithWindow = true
    @view.frameLoadDelegate = self    
    @toolbar.selectedItemIdentifier = itemForView(:dashboard).itemIdentifier
    activateHtmlView(:dashboard)    
    setSpecFileViewLabel(:disabled => true)    
  end  
  
  def toolbarSelectableItemIdentifiers(toolbar)
    @toolbaridents ||= begin
      @toolbar.items.collect {|i| i.itemIdentifier }
    end
  end  
  
  def webView_didFinishLoadForFrame(view, frame)
    @@afterLoadBlock.call if @@afterLoadBlock
  end
  
  def loadHtml(file_name, &block)
    @view.isLoading # dumb
    @@afterLoadBlock = block
    @view.mainFrameURL = File.join(File.dirname(__FILE__), file_name)
  end
  
  def showSpecFileViewFromTable(notification)
    showSpecFileViewFromIndex(notification.userInfo.first.selectedRow)
  end
  
  def showSpecFileViewFromSpec(notification)
    showSpecFileView(notification.userInfo.first.file_object)
  end
  
  def showSpecFileViewFromIndex(index)
    showSpecFileView(ExampleFiles.file_by_index(index))
  end
  
  def showSpecFileView(file)
    if file.nil? && !self.current_spec_file_view
      setSpecFileViewLabel(:disabled => true)
      activateHtmlView(:dashboard) and return
    end
    
    if file && (!defined?(@@currently_displayed_file) || file != @@currently_displayed_file)
      @@currently_displayed_file = file
      @current_spec_file_view.file = @@currently_displayed_file if @current_spec_file_view
      setSpecFileViewLabel(:disabled => true)
    end
    
    activateHtmlView(:spec_view) do
      @current_spec_file_view ||= SpecFileView.new(@view, @@currently_displayed_file)
      @current_spec_file_view.update
      setSpecFileViewLabel(:disabled => false)
    end
  end
  
  def showRawOutputView
    activateHtmlView(:output) do
      view = RawOutputView.new(@view)
      view.update
    end    
  end
  
  def editor_integration_enabled?
    $app.default_from_key(:editor_integration) == '1'
  end
  
  def reloadWebView(notification)
    return unless defined?(@@currently_displayed_file)
    if @@currently_displayed_file == notification.userInfo.first.file_object
      showSpecFileView(@@currently_displayed_file)
    end
  end
  
  def reloadWebViewForSpecs(notification)
    return unless defined?(@@currently_displayed_file)
    notification.userInfo.first.each do |spec|
      if spec.file_object && @@currently_displayed_file.path == spec.file_object.path
        showSpecFileView(@@currently_displayed_file)
        return true
      end
    end
  end
  
  def webView_runJavaScriptAlertPanelWithMessage(webview, message)
    return unless editor_integration_enabled?
    case $app.default_from_key(:editor)
    when 'TextMate'
      TextMate.open_file_with_line(message)
    when 'Netbeans'
      Netbeans.open_file_with_line(message)
    end
  end

  def tagForView(view)
    case view
    when :dashboard: 0
    when :output:    1
    when :spec_view: 2
    end
  end
  
  def itemForView(view)
    tag = tagForView(view)
    @toolbar.items.select { |i| i.tag == tag }.first
  end
  
  def activateHtmlView(view, &block)    
    @toolbar.selectedItemIdentifier = itemForView(view).itemIdentifier
    loadHtmlView(view, &block)
  end
  
  def loadHtmlView(view, &block)
    case view
    when :dashboard: loadHtml('dashboard.html', &block)
    when :output: loadHtml('raw_output.html', &block)
    when :spec_view: loadHtml('spec_file.html', &block)
    end
  end  
    
  def setSpecFileViewLabel(options = {})
    itemForView(:spec_view).enabled = !options[:disabled] || options[:disabled] == false
  end  
end
