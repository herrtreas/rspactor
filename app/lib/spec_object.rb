class SpecObject

  attr_accessor :state
  attr_accessor :name, :example_group_name
  attr_accessor :message
  attr_accessor :full_file_path, :file, :line
  attr_accessor :error_header, :error_type, :backtrace

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
  
  # Implement this using regexp and $1, $2 etc..
  def backtrace=(trace)
    @backtrace = trace
    @file = trace[0].split("/").last.split(":").first
    @full_file_path = trace[0].split(":").first
    @line = trace[0].split(":")[1].to_i
  end
  
  def source
    return [] unless @full_file_path && @line
    unless @source
      @source = source_from_file(full_file_path, @line.to_i)
    end
    @source
  end
  
  
  private
        
  def source_from_file(file, line)
    return [] unless File.exist?(file)
    File.open(file, 'r') { |f| @lines = f.readlines }
    @lines = @lines.map { |l| l.chomp }
    first_line = [0, line - 3].max
    last_line = [line + 6, @lines.length - 1].min
    @lines[first_line..last_line]
  end
  
end
