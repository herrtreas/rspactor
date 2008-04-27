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
    html =  ''
    html << "<p class='title failed'>#{spec.message}</p>"
    html << source_to_html(spec)
    html << formatted_backtrace(spec)
    html
  end
  
  def html_content_for_pending(spec)
    html =  ''
    html << "<p class='title'>#{spec.message}</p>"
    html << source_to_html(spec)
    html
  end
  
  def html_content_for_passed(spec)
    source_to_html(spec)
  end
  
  def source_to_html(spec)
    @converter ||= Syntax::Convertors::HTML.for_syntax "ruby"
    add_lineml(@converter.convert(spec.source.join("\n"), false), spec)
  end
  
  def add_lineml(source, spec)
    current_line = spec.line.to_i
    lines = ["<ul class=\"code_view\">"]
    
    source_lines = source.split("\n")
    base_line_start = current_line - 2
    max_line_number = base_line_start + (source_lines.size - 1)
    
    source_lines.each_with_index do |l, i|
      line_number = ('&nbsp;' * (max_line_number.to_s.size - (base_line_start + i).to_s.size)) + "#{base_line_start + i}"
      line_class = if i + current_line - 2 == current_line
        'current'
      else
        (i % 2 == 0) ? 'even' : 'odd' 
      end
      
      lines << "<li class=\"#{line_class}\">"
      lines << "<span class=\"linenumber\">#{line_number}</span>#{l}"
      lines << "</li>"
    end
    lines << "</ul>"
    "<div class='code' onclick='#{ext_file_alert(spec.full_file_path, spec.line)}'>#{lines.join("\n")}</div>"
  end
  
  def ext_file_alert(full_file_path, line)
     "alert(\"#{External.file_link(full_file_path, line)}\")"
  end
  
  def formatted_backtrace(spec)
    html =  ''
    spec.backtrace.each do |trace_line|
      ext_alert = ext_file_alert(trace_line.split(':')[0], trace_line.split(':')[1]) 
      html << "<li><a href='javascript:#{ext_alert}'>#{trace_line}</a></li>"
    end    
    "<ul class='trace'>#{html}</ul>"
  end
end
