require 'osx/cocoa'

class SpecFileView < HtmlView
  attr_accessor :file_index
  
  def initialize(webview, file_index)
    @web_view = webview
    @file_index = file_index
  end
  
  def update
    file = $spec_list.file_by_index(@file_index)
    return unless file
    setInnerHTML('title', file.name)
    setInnerHTML('subtitle', file.full_path)
    
    spec_html = '<ul class="spec">'
    file.specs.each do |spec|
      spec_html << '<li class="spec">'
      spec_html << "<p class='spec_title spec_title_#{spec.state}' onclick='toggleSpecBox(this);'>"
      spec_html << fold_button(spec)
      spec_html << "#{spec.to_s}"
      spec_html << "</p>"
      spec_html << "<div #{spec.state == :passed ? "style='display: none'" : ""}>"
      spec_html << "<p class='spec_message'>#{h(spec.message)}</p>" if spec.message
      spec_html << "<p class='spec_code'>#{Converter.source_to_html(spec)}</p>"
      spec_html << "<ul class='spec_trace'>#{Converter.formatted_backtrace(spec)}</ul>" if spec.state == :failed
      spec_html << '</div>'
      spec_html << '</li>'
    end
    spec_html << '</ul>'
    setInnerHTML('content', spec_html)
  end
  
  def fold_button(spec)
    button = spec.state == :passed ? "+" : "-"
    "<span class='fold_button'>#{button}</span>"
  end
end