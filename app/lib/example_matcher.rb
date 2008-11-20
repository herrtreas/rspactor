class ExampleMatcher
  def self.init
    @@_include_directories = /vendor\/plugins\/jade/
    @@_exclude_directories = /vendor|\.git|build/
    @@_file_extensions = %w(.rb .erb .haml .rhtml)
  end
  
  def self.match_file_pairs(file, example_files)
    match_file_name = spec_name_from_file(file)
    file_name = File.basename(file)
    grep_res = example_files.keys.grep(Regexp.new(match_file_name))
    
    result_file = nil
    if grep_res.size == 1
      result_file = grep_res.first
    elsif grep_res.size > 1
      result_file = match_files_by_path(file, match_file_name, grep_res)
    end
    
    return (result_file && file_is_valid?(result_file)) ? result_file : nil
  end  
  
  def self.match_files_by_path(file, spec_file_name, grep_res)
    file_parts = File.dirname(file).split('/')
    path_prefix = ''
    while !file_parts.empty?
      path_prefix = File.join(file_parts.pop, path_prefix)
      grep_res.each { |spec_file| return spec_file if spec_file.match(path_prefix + spec_file_name) }
    end        
  end
  
  def self.spec_name_from_file(file)
    if File.extname(file) == '.rb'
      File.basename(file, File.extname(file)) + "_spec#{File.extname(file)}"
    else
      File.basename(file, File.extname(file)) + "#{File.extname(file)}_spec.rb"
    end
  end  
  
  def self.file_is_a_spec?(file)
      file =~ /_spec\.rb$/ ? true : false
  end
  
  def self.file_is_valid?(file)
    unless File.dirname(file) =~ @@_include_directories
      return false if File.dirname(file) =~ @@_exclude_directories
    end
    file =~ Regexp.new(@@_file_extensions.collect{|e| "\\#{e}$"}.join('|')) ? true : false
  end  
end