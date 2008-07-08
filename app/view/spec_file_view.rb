require 'osx/cocoa'

class SpecFileView < HtmlView
  attr_accessor :file_index
  
  def initialize(webview, file_index)
    @web_view = webview
    @file_index = file_index
  end
  
  def update
    file = $spec_list.file_by_index(@file_index)
    setInnerHTML('title', file.name)
    setInnerHTML('subtitle', file.full_path)
    
    spec_html = '<ul>'
    file.specs.each do |spec|
      spec_html << '<li>'
      spec_html << "<p class='spec_title #{spec.state}'>#{spec.to_s}</p>"
      spec_html << "<p class='spec_message'>#{h(spec.message)}</p>"
      spec_html << "<p class='spec_code'>#{Converter.source_to_html(spec)}</p>"
      spec_html << "<p class='spec_trace'></p>"
      spec_html << '</li>'
    end
    spec_html << '</ul>'
    setInnerHTML('content', spec_html)
  end
end