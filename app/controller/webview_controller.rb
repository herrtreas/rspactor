require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  ib_outlet :view, :tabBar  
  ib_action :tabBarClicked
  
  attr_accessor :current_spec_file_view
  
  def awakeFromNib
    receive :fileToWebViewLoadingRequired,              :showSpecFileViewFromTable
    receive :first_failed_spec,                         :showSpecFileViewFromSpec
    receive :spec_run_processed,                        :reloadWebView
    
    @view.shouldCloseWithWindow = true
    @view.frameLoadDelegate = self    
    setupTabBar :dashboard
  end  
  
  def webView_didFinishLoadForFrame(view, frame)
    @@afterLoadBlock.call if @@afterLoadBlock
  end
  
  def loadHtml(file_name, &block)
    # $LOG.debug "Test: #{@view.isLoading}"
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
      labelForView(:spec_view, '..', :disabled => true)
      activateHtmlView(:dashboard) and return
    end
    
    if file && (!defined?(@@currently_displayed_file) || file != @@currently_displayed_file)
      @@currently_displayed_file = file
      @current_spec_file_view.file = @@currently_displayed_file if @current_spec_file_view
      labelForView(:spec_view, 'Loading..', :disabled => true)
    end
    
    activateHtmlView(:spec_view) do
      @current_spec_file_view ||= SpecFileView.new(@view, @@currently_displayed_file)
      @current_spec_file_view.update
      labelForView(:spec_view, @current_spec_file_view.file.name(:include => :spec_count))
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
  
  def webView_runJavaScriptAlertPanelWithMessage(webview, message)
    return unless editor_integration_enabled?
    case $app.default_from_key(:editor)
    when 'TextMate'
      TextMate.open_file_with_line(message)
    when 'Netbeans'
      Netbeans.open_file_with_line(message)
    end
  end

  def tabBarClicked(sender)
    # $LOG.debug @tabBar.selectedSegment
    case @tabBar.selectedSegment
    when 0:
      loadHtmlView
    when 1:
      showRawOutputView
    when 2:
      if defined?(@@currently_displayed_file)
        showSpecFileView(@@currently_displayed_file)
      else
        labelForView(:spec_view, '..', :disabled => true)
        activateHtmlView(:dashboard)
      end
    end
  end
  
  def indexForView(view)
    case view
    when :dashboard: 0
    when :output:    1
    when :spec_view: 2
    end
  end
  
  def setupTabBar(view)
    @tabBar.setWidth_forSegment(100.0, 0)
    @tabBar.setWidth_forSegment(100.0, 1)    
    @tabBar.setWidth_forSegment(0, 2)    
    activateHtmlView(view)
  end
  
  def activateHtmlView(view, &block)    
    @tabBar.selectedSegment = indexForView(view)
    loadHtmlView(&block)
  end
  
  def loadHtmlView(&block)
    case @tabBar.selectedSegment
    when 0: loadHtml('dashboard.html', &block)
    when 1: loadHtml('raw_output.html', &block)
    when 2: loadHtml('spec_file.html', &block)
    end
  end  
    
  def labelForView(view, label, options = {})
    index = indexForView(view)
    @tabBar.setEnabled_forSegment(!options[:disabled], index)
    @tabBar.setLabel_forSegment(label, index)
  end  
end
