require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  ib_outlet :view
  
  def awakeFromNib
    receive :NSTableViewSelectionDidChangeNotification, :showSpecFileViewFromTable
    receive :first_failed_spec,                         :showSpecFileViewFromSpec
    receive :spec_run_processed,                        :reloadWebView
    @view.shouldCloseWithWindow = true
    @view.frameLoadDelegate = self    
    loadHtml('welcome.html')
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
    loadHtml('welcome.html') and return if row_index < 0
    
    @@currently_displayed_row_index = row_index
    loadHtml('spec_file.html') do
      view = SpecFileView.new(@view, row_index)
      view.update
    end
  end
  
  def reloadWebView(notification)
    return unless defined?(@@currently_displayed_row_index)
    if @@currently_displayed_row_index == $spec_list.index_by_spec(notification.userInfo.first)
      showSpecFileView(@@currently_displayed_row_index)
    end
  end
  
  def webView_runJavaScriptAlertPanelWithMessage(webview, message)
    TextMate.open_file_with_line(message)
  end  
end
