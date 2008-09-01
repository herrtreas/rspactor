module TextMate
  class << self
    def open_file_with_line(path_with_line)
      bin_path = $app.default_from_key(:tm_bin_path).chomp.strip
      file, line = path_with_line.split(':')
      $LOG.debug "External: TM: " + "#{bin_path} --line #{line} #{file}"
      Kernel.system("#{bin_path} --line #{line} #{file}")      
    end
  end
end