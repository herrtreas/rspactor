require 'osx/cocoa'

class SpecFileView < HtmlView
  attr_accessor :file_index
  attr_accessor :file
  
  def initialize(webview, file)
    @web_view = webview
    self.file = file
  end
  
  def update
    setInnerHTML('title', @file.name)
    setInnerHTML('subtitle', @file.path)
    
    spec_html = '<ul class="spec">'
    @file.sorted_specs.each do |spec|
      spec_html << '<li class="spec">'
      spec_html << "<p class='spec_title spec_title_#{spec.state}' onclick='toggleSpecBox(this);'>"
      spec_html << fold_button(spec)
      spec_html << "#{spec.to_s}"
      spec_html << "</p>"
      spec_html << "<div #{spec.state == :passed ? "style='display: none'" : ""}>"
      spec_html << "<p class='spec_message'>#{h(spec.message)}</p>" if spec.message
      if spec.full_file_path != spec.file_of_first_backtrace_line
        spec_html << "<div class='sub_file_path'>#{spec.file_of_first_backtrace_line}</div>"
        spec_html << "<p class='spec_code'>#{Converter.source_to_html(spec, :force_file_at_first_backtrace_line => true)}</p>"
        spec_html << "<div class='sub_file_path'>#{spec.full_file_path}</div>"
      end
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