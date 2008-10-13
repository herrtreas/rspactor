require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  ib_outlet :view, :tabBar  
  ib_action :tabBarClicked
  
  def awakeFromNib
    receive :NSTableViewSelectionDidChangeNotification, :showSpecFileViewFromTable
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
    @@afterLoadBlock = block
    @view.mainFrameURL = File.join(File.dirname(__FILE__), file_name)
  end
  
  def showSpecFileViewFromTable(notification)
    showSpecFileView(notification.object.selectedRow)
  end
  
  def showSpecFileViewFromSpec(notification)
    showSpecFileView($spec_list.index_by_spec(notification.userInfo.first))
  end
  
  def showSpecFileView(row_index)    
    if row_index < 0 && @@currently_displayed_row_index.nil?
      activateHtmlView(:dashboard) and return
    end
    
    if row_index >= 0 && (!defined?(@@currently_displayed_row_index) || row_index != @@currently_displayed_row_index)
      @@currently_displayed_row_index = row_index 
      labelForView(:spec_view, 'Loading..', :disabled => true)
    end
    
    activateHtmlView(:spec_view) do
      view = SpecFileView.new(@view, @@currently_displayed_row_index)
      view.update
      labelForView(:spec_view, view.file_name)
    end
  end
  
  def editor_integration_enabled?
    $app.default_from_key(:editor_integration) == '1'
  end
  
  def reloadWebView(notification)
    return unless defined?(@@currently_displayed_row_index)
    if @@currently_displayed_row_index == $spec_list.index_by_spec(notification.userInfo.first)
      showSpecFileView(@@currently_displayed_row_index)
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
    case @tabBar.selectedSegment
    when 0, 1:
      loadHtmlView
    when 2:
      if @@currently_displayed_row_index
        showSpecFileView(@@currently_displayed_row_index)
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
    when 0: loadHtml('welcome.html', &block)
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
