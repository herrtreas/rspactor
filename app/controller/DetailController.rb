#
#  DetailController.rb
#  RSpactor
#
#  Created by Andreas Wolff on 21.04.08.
#

require 'osx/cocoa'

class DetailController < OSX::NSWindowController
  ib_outlet :webView
  
  def init
    $details = self
    super_init
  end
  
  def awakeFromNib
    @webView.mainFrameURL = File.join(File.dirname(__FILE__), "detail_view.html")
  end
  
  def setContentFromSpec(spec)
    clear
    html = ''
        
    case spec.state
    when :passed
      html = html_content_for_passed(spec)
    when :failed
      html = html_content_for_failed(spec)
    when :pending
      html = html_content_for_pending(spec)
    end
    
    @webView.mainFrame.DOMDocument.getElementById('content').setInnerHTML(html)
  end
  
  def setError(message)
    html = message
    @webView.mainFrame.DOMDocument.getElementById('content').setInnerHTML(html)
  end
  
  def clear
    @webView.mainFrame.DOMDocument.getElementById('content').setInnerHTML('')
  end
  
  
  private
  
  def html_content_for_failed(spec)
    html = [spec.message, "#{spec.error_file}:#{spec.error_line}", spec.backtrace].join("<br />")
    html
  end
  
  def html_content_for_pending(spec)
    html = [spec.message].join("<br />")
  end
  
  def html_content_for_passed(spec)
    ''
  end
  
end
