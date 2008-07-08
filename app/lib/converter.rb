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
#      "<div class='code' onclick='#{ext_file_alert(spec.full_file_path, spec.line)}'>#{lines.join("\n")}</div>"
      "<div class='code'>#{lines.join("\n")}</div>"
    end
    # 
    # def ext_file_alert(full_file_path, line)
    #    "alert(\"#{External.file_link(full_file_path, line)}\")"
    # end
    # 
    # def formatted_backtrace(spec)
    #   html =  ''
    #   spec.backtrace.each do |trace_line|
    #     ext_alert = ext_file_alert(trace_line.split(':')[0], trace_line.split(':')[1]) 
    #     html << "<li><a href='javascript:#{ext_alert}'>#{trace_line}</a></li>"
    #   end    
    #   "<ul class='trace'>#{html}</ul>"
    # end    
  end
end