module Netbeans
  class << self
    def open_file_with_line(path_with_line)
      bin_path = $app.default_from_key(:nb_bin_path).chomp.strip
      file, line = path_with_line.split(':')
      $LOG.debug "External: NB: " + "#{bin_path} --open #{file}:#{line}"
      Kernel.system("#{bin_path} --open #{file}:#{line}")      
    end
  end
end