require 'osx/cocoa'

class RawOutputView < HtmlView  
  def initialize(webview)
    @web_view = webview
  end  
  
  def update
    return if $raw_output.empty?
    html = '<ul class="raw_output">'
    $raw_output.compact.each do |output|
      html << '<li>'
      html << "<small>#{output[0].strftime("%b %d, %H:%M:%S")}</small>"
      html << '<hr>'
      html << "<pre>#{output[1]}</pre>"
      html << '</li>'
    end
    html << '</ul>'
    setInnerHTML('content', html)    
  end
end