class ExampleFiles
  def self.init
    @@filter = :all
    @@example_files = {}
    @@_sorted_files = []
    ExampleMatcher.init
  end
  
  def self.filter=(filter)
    if filter != @@filter
      @@filter = filter
      self.update_sorted_list
    end
  end
  
  def self.add_spec(spec)
    example_file = find_or_create_example_file_by_spec(spec)
    example_file.add_spec(spec)
    self.update_sorted_list
  end
  
  def self.tainting_required_on_all_files!
    @@example_files.each { |path, ef| ef.tainting_required! }
  end
  
  def self.total_failed_spec_count
    failed_spec_count = 0
    @@example_files.each { |path, file| failed_spec_count += file.spec_count(:failed)  }
    failed_spec_count
  end
  
  def self.files_count
    @@_sorted_files.size
  end
  
  def self.file_by_index(index)
    file = @@example_files[@@_sorted_files[index]]
    file.remove_tainted_specs if file
    file
  end
  
  def self.clear_suicided_files!
    unless @@example_files.delete_if { |path, file| file.suicide? }.empty?
      self.update_sorted_list
      $app.post_notification :file_table_reload_required      
    end
  end
  
  def self.index_for_file(file)
    @@_sorted_files.index(file.path)
  end
  
  def self.find_example_for_file(file_path)
    if @@example_files[file_path]
      file_path
    elsif ExampleMatcher.file_is_a_spec?(file_path)
      @@example_files[file_path] = ExampleFile.new(:path => file_path)
      self.update_sorted_list
      file_path
    else
      ExampleMatcher.match_file_pairs(file_path, @@example_files)
    end
  end
  
  def self.clear!
    @@example_files = {}
    @@_sorted_files = []
  end
  
  private
  
  def self.find_or_create_example_file_by_spec(spec)
    return @@example_files[spec.full_file_path] if @@example_files[spec.full_file_path]
    example_file = ExampleFile.new(:path => spec.full_file_path)
    @@example_files[example_file.path] = example_file
    example_file
  end
  
  def self.update_sorted_list
    case @@filter
    when :all
      @@_sorted_files = @@example_files.sort { |a,b| b[1].mtime <=> a[1].mtime }.collect { |f| f[0] }
    when :failed
      @@_sorted_files = @@example_files.select { |path, ef| ef.failed? }.sort { |a,b| a[1].mtime <=> b[1].mtime }.collect { |f| f[0] }
    end
  end  
end