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
    @webView.shouldCloseWithWindow = true
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
  
  def webView_contextMenuItemsForElement_defaultMenuItems(webview, dict, defaultMenuItems)
    []
  end
  
  # We misuse alert to open files.. Thats easy :D
  def webView_runJavaScriptAlertPanelWithMessage(webview, message)
    External.open_editor_with_file_from_ext_link(message)
  end
  
  
  private
  
  def html_content_for_failed(spec)
    [spec.message, source_to_html(spec), formatted_backtrace(spec)].join("<br />")
  end
  
  def html_content_for_pending(spec)
    [spec.message, source_to_html(spec)].join("<br />")
  end
  
  def html_content_for_passed(spec)
    source_to_html(spec)
  end
  
  def source_to_html(spec)
    @converter ||= Syntax::Convertors::HTML.for_syntax "ruby"
    add_lineml(@converter.convert(spec.source.join("\n"), false), spec)
  end
  
  def add_lineml(source, spec)
    line = spec.line.to_i
    lines = []
    source.split("\n").each_with_index do |l, i|
      html = "<span class=\"linenumber\">#{line+i-2}</span>#{l}"
      html = "<span class=\"pointer\">#{html}</span>" if i + line - 2 == line
      lines << html
    end
    "<div class='code' onclick='#{ext_file_alert(spec.full_file_path, spec.line)}'><pre>#{lines.join("\n")}</pre></div>"
  end
  
  def ext_file_alert(full_file_path, line)
     "alert(\"#{External.file_link(full_file_path, line)}\")"
  end
  
  def formatted_backtrace(spec)
    html =  ''
    spec.backtrace.each do |trace_line|
      ext_alert = ext_file_alert(trace_line.split(':').first, trace_line.split(':').last) 
      html << "<li><a href='javascript:#{ext_alert}'>#{trace_line}</a></li>"
    end    
    "<ul>#{html}</ul>"
  end
end
