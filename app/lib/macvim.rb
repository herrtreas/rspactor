module MacVim
  class << self
    def open_file_with_line(path_with_line)
      bin_path = $app.default_from_key(:editor_bin_path).chomp.strip
      file, line = path_with_line.split(':')
      $LOG.debug "External: MVIM: " + "#{bin_path} +#{line} #{file}"
      Kernel.system("#{bin_path} --remote-silent +#{line} #{file}")      
    end
  end
end
