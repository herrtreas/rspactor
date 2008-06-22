require 'osx/cocoa'

class WebviewController < OSX::NSWindowController
  ib_outlet :view
  
  def awakeFromNib
    receive :NSTableViewSelectionDidChangeNotification, :showSpecFileViewFromTable
    receive :first_failed_spec,                         :showSpecFileViewFromSpec
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
    loadHtml('spec_file.html') do
      view = SpecFileView.new(@view, row_index)
      view.update
    end
  end
end
