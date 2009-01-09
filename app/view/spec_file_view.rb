require 'osx/cocoa'

class SpecFileView < HtmlView
  attr_accessor :file_index
  attr_accessor :file  
  
  def initialize(webview, file)
    @web_view = webview
    self.file = file
  end
  
  def update(opts = {})
    setInnerHTML('title', @file.name)
    setInnerHTML('subtitle', @file.path)
    spec_html = ''
    
    if opts[:only]
      specs_to_show = [@file.spec_by_id(opts[:only])]
      spec_html << "<h3><a href='#' onclick='alert(\"#{@file.path}@spec_view_from_file_path\")'>Show all examples</a></h3>"
    else
      specs_to_show = @file.sorted_specs
    end

    spec_html << '<ul class="spec">'
    specs_to_show.each do |spec|
      spec_html << '<li class="spec">'
      spec_html << "<p class='spec_title spec_title_#{spec.state}' onclick='toggleSpecBox(this);'>"
      spec_html << fold_button(spec, :expanded => true)
      spec_html << "#{spec.to_s}"
      spec_html << "</p>"
      spec_html << "<div #{spec.state == :passed && !opts[:only] ? "style='display: none'" : ""}>"
      spec_html << formatted_message(h(spec.message)) if spec.message
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
  
  def fold_button(spec, opts = {})
    button = spec.state == :passed && !opts[:expanded] ? "+" : "-"
    "<span class='fold_button'>#{button}</span>"
  end

  # inspired by Rails's ActionView::Helpers::TextHelper#simpleFormat
  def formatted_message(text)
    start_tag = %Q(<p class="spec_message">)
    text = text.to_s.dup
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "</p>\n\n<p>")  # 2+ newline  -> paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.insert 0, start_tag
    text << "</p>"
  end

end