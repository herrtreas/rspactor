require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  attr_accessor :current_spec_file_view
  
  VIEWS = {
    :dashboard  => { :tag => 0, :file => 'dashboard.html' },
    :output     => { :tag => 1, :file => 'raw_output.html' },
    :spec_view  => { :tag => 2, :file => 'spec_file.html' }
  }
  
  ib_outlet :view, :tabBar, :toolbar
    
  ib_action :toolbarItemClicked do |sender|
    @toolbar.selectedItemIdentifier = sender.itemIdentifier
    case sender.tag
    when 0:
      showDashboardView
    when 1:
      showRawOutputView
    when 2:
      showSpecFileView(@currently_displayed_file)
    end    
  end
  
  def awakeFromNib
    @view.shouldCloseWithWindow = true
    @view.frameLoadDelegate = self    
    @toolbar.selectedItemIdentifier = itemForView(:dashboard).itemIdentifier
    setSpecFileViewLabel(:disabled => true)    
    showDashboardView
    hook_events
  end  
  
  def toolbarSelectableItemIdentifiers(toolbar)
    @toolbaridents ||= begin
      @toolbar.items.select { |i| [0,1,2].include?(i.tag) }.collect {|i| i.itemIdentifier }
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
  
  def itemForView(view)
    @toolbar.items.select { |i| i.tag == VIEWS[view][:tag] }.first
  end
  
  def activateHtmlView(view, &block)    
    @toolbar.selectedItemIdentifier = itemForView(view).itemIdentifier
    loadHtmlView(view, &block)
  end
  
  def loadHtmlView(view, &block)
    loadHtml(VIEWS[view][:file], &block)
  end  
    
  def setSpecFileViewLabel(options = {})
    itemForView(:spec_view).enabled = !options[:disabled] || options[:disabled] == false
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
  
  def showSpecFileViewForSingleSpec(spec_id)
    showSpecFileView(ExampleFiles.file_by_spec_id(spec_id), :only => spec_id)
  end
  
  def showSpecFileViewFromFilePath(file_path)
    showSpecFileView(ExampleFiles.file_by_path(file_path))
  end
  
  def showSpecFileView(file, opts = {})
    if file.nil? && !self.current_spec_file_view
      setSpecFileViewLabel(:disabled => true)
      showDashboardView and return
    end
    
    if file && (!@currently_displayed_file || file != @currently_displayed_file)
      @currently_displayed_file = file
      @current_spec_file_view.file = @currently_displayed_file if @current_spec_file_view
      setSpecFileViewLabel(:disabled => true)
    end
    
    activateHtmlView(:spec_view) do
      @current_spec_file_view ||= SpecFileView.new(@view, @currently_displayed_file)
      @current_spec_file_view.update(opts)
      setSpecFileViewLabel(:disabled => false)
    end
  end
  
  def showRawOutputView
    activateHtmlView(:output) do
      view = RawOutputView.new(@view)
      view.update
    end    
  end
  
  def showDashboardView
    activateHtmlView(:dashboard) do
      view = DashboardView.new(@view)
      view.update
    end    
  end
  
  def editor_integration_enabled?
    $app.default_from_key(:editor_integration) == '1'
  end
  
  def reloadWebViewBeforeExampleRun(notification)
    reloadIfSelected [:dashboard], notification
  end
  
  def reloadWebView(notification)
    reloadIfSelected [:spec_view], notification    
  end
  
  def reloadWebViewForSpecs(notification)
    return unless @currently_displayed_file
    notification.userInfo.first.each do |spec|
      if spec.file_object && @currently_displayed_file.path == spec.file_object.path
        showSpecFileView(@currently_displayed_file)
        return true
      end
    end
  end
  
  def reloadWebViewAfterExampleRun(notification)
    reloadIfSelected [:dashboard], notification
  end
  
  def reloadIfSelected(views, notification)
    case @toolbar.selectedItemIdentifier
    when itemForView(:dashboard).itemIdentifier
      showDashboardView if views.include?(:dashboard)
    when itemForView(:spec_view).itemIdentifier
      if views.include?(:spec_view) && @currently_displayed_file && @currently_displayed_file == notification.userInfo.first.file_object
        showSpecFileView(@currently_displayed_file)
      end
    end     
  end
  
  def webView_runJavaScriptAlertPanelWithMessage(webview, message)
    message, context = message.split('@')
    if context == 'external'
      return unless editor_integration_enabled?
      case $app.default_from_key(:editor)
      when 'TextMate'
        TextMate.open_file_with_line(message)
      when 'Netbeans'
        Netbeans.open_file_with_line(message)
      else
        TextMate.open_file_with_line(message)
      end
    elsif context == 'spec_view'
      showSpecFileViewForSingleSpec(message)
    elsif context == 'spec_view_from_file_path'
      showSpecFileViewFromFilePath(message)
    else
      $LOG.debug "No context given: #{message}"
    end
  end
  
  def hook_events
    receive :fileToWebViewLoadingRequired,              :showSpecFileViewFromTable
    receive :first_failed_spec,                         :showSpecFileViewFromSpec
    receive :spec_run_start,                            :reloadWebViewBeforeExampleRun
    receive :spec_run_processed,                        :reloadWebView
    receive :example_run_global_complete,               :reloadWebViewAfterExampleRun
    receive :webview_reload_required_for_specs,         :reloadWebViewForSpecs    
  end
end
