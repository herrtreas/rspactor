module Converter
  class << self
    def source_to_html(spec)
      @converter ||= Syntax::Convertors::HTML.for_syntax "ruby"
      render_html(@converter.convert(spec.source.join("\n"), false), spec)
    end

    def render_html(source, spec)
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
      
      alert_line = spec.full_file_path + ':' + spec.line.to_s
      css_class = ($app.default_from_key(:editor_integration) == '1') ? 'code editor_integration_enabled' : 'code'
      "<div class='#{css_class}' onclick='alert(\"#{alert_line}\")'>#{lines.join("\n")}</div>"
    end
    
    def formatted_backtrace(spec)
      spec.backtrace.collect do |trace_line|
        alert_line = trim_line_for_alert(trace_line)
        "<li><a href='#' onclick='alert(\"#{alert_line}\")'>#{trace_line}</a></li>"
      end.join('')
    end

    def trim_line_for_alert(line)
      line.split(':')[0...2].join(':')
    end
    
  end
end