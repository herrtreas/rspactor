class External
  def self.file_link(file_path, line)
    "#{file_path}:#{line}"
  end
  
  def self.open_editor_with_file_from_ext_link(ext_link)
    file, line = ext_link.split(':')
    system("mate --line #{line} #{file}")
  end
end
