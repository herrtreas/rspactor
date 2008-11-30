class SpecObject

  attr_accessor :state, :previous_state
  attr_accessor :name, :example_group_name
  attr_accessor :message
  attr_accessor :full_file_path, :file, :line
  attr_accessor :error_header, :error_type, :backtrace
  attr_accessor :file_object

  def initialize(opts = {})
    opts.each do |key, value| 
      self.send("#{key.to_s}=".intern, value) rescue next
    end
  end

  def to_s
    "#{@example_group_name} #{@name}"
  end
  
  def message=(msg)
    msg[0...1] = msg[0...1].upcase  # Make the first word upper case..
    @message = msg
  end
  
  # TODO: Implement this using regexp and $1, $2 etc..
  def backtrace=(trace)
    @backtrace = trace
    line_containing_spec = trace.select { |l| l.include?('_spec.rb') }.first || trace.first
    @file = line_containing_spec.split("/").last.split(":").first
    @full_file_path = line_containing_spec.split(":").first
    @line = line_containing_spec.split(":")[1].to_i
  end
  
  def source(opts = {})
    if opts[:force_file_at_first_backtrace_line]
      source_from_file(file_of_first_backtrace_line, line_number_of_first_backtrace_line)
    else
      return [] unless @full_file_path && @line
      unless @source
        @source = source_from_file(full_file_path, @line.to_i)
      end
      @source
    end
  end
  
  def file_of_first_backtrace_line
    file = self.backtrace.first.split(':')[0]
  end
  
  def line_number_of_first_backtrace_line
    line = self.backtrace.first.split(':')[1].to_i || 0    
  end
  
  
  private
        
  def source_from_file(file, line)
    return [] unless File.exist?(file)
    File.open(file, 'r') { |f| @lines = f.readlines }
    lines = @lines.map { |l| l.chomp }
    first_line = [0, line - 3].max
    last_line = [line + 6, lines.length - 1].min
    lines[first_line..last_line]
  end
  
end
