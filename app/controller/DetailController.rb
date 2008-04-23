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
  
  
  private
  
  def html_content_for_failed(spec)
    [spec.message, source_to_html(spec.source, spec.line.to_i), "#{spec.file}:#{spec.line}", spec.backtrace].join("<br />")
  end
  
  def html_content_for_pending(spec)
    [spec.message, source_to_html(spec.source, spec.line.to_i)].join("<br />")
  end
  
  def html_content_for_passed(spec)
    source_to_html(spec.source, spec.line.to_i)
  end
  
  def source_to_html(source, line)
    @converter ||= Syntax::Convertors::HTML.for_syntax "ruby"
    add_lineml(@converter.convert(source.join("\n"), false), line)
  end
  
  def add_lineml(source, line)
    lines = []
    source.split("\n").each_with_index do |l, i|
      html = "<span class=\"linenumber\">#{line+i-2}</span>#{l}"
      html = "<span class=\"pointer\">#{html}</span>" if i + line - 2 == line
      lines << html
    end
    "<div class='code'><pre>#{lines.join("\n")}</pre></div>"
  end
  
end
