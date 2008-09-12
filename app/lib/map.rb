class Map
  attr_accessor :exclude_directories, :include_directories
  attr_accessor :root
  attr_accessor :file_extensions
  attr_reader   :files      
  
  
  def self.ensure(path, &block)
    Thread.start do 
      $LOG.debug 'Ensuring map..'
      wait_if_map_is_currently_building
      location_has_changed(path)
      unless $map && $map.created? && $map.root == $path
        $LOG.debug "Rebuilding map in #{path}.."
        $map = Map.new
        $map.root = path
        $map.create
        $LOG.debug "Map for #{path} created"
      end
      yield if block_given?
    end
  end
  
  def self.wait_if_map_is_currently_building
    return unless defined?(@@creating_map) || (defined?(@@creating_map) && @@creating_map == true)
    while @@creating_map == true
      sleep 0.1
    end
  end
  
  def self.location_has_changed(new_path)
    if $map && $map.root != new_path
      $spec_list.clear!
      $app.post_notification(:map_location_changed) 
    end
  end  
  
  def initialize
    @files = {}
    self.include_directories = /vendor\/plugins\/jade/
    self.exclude_directories = /vendor|\.git|build/
    self.file_extensions = %w(.rb .erb .haml .rhtml)
  end
  
  def create
    lock_during_map_creation do
      @files = {}
      @found_files = []
      glob_files_in_path(@root, self.file_extensions)
      @found_files.each do |f|
        next unless file_is_valid?(f)
        next if f =~ /_spec.rb$/
        spec_file_name = spec_name_from_file(f)
        spec_file = match_file_pairs(@found_files, f, spec_file_name)
        @files[f] = (spec_file) ? spec_file.strip.chomp : ''
      end
      @created = true
    end
  end
  
  def lock_during_map_creation(&block)
    @@creating_map = true
    yield
    @@creating_map = false
  end
  
  def [](file)
    return nil unless file_is_valid?(file)
    if is_spec?(file) # TODO: Check if mapping file is in list but empty  #TODO: Verify that todo
      matching_file = file_by_spec(file)
      if matching_file && @files[matching_file] == ''
        @files[matching_file] = file.strip.chomp if matching_file
      end
      return file
    end
    
    if @files[file].nil? || @files[file] == ''
      return nil               
    else                          
      return @files[file]
    end
  end
  
  def file_by_spec(spec)
    file_name = file_name_from_spec(spec)
    files = glob_files_in_path(self.root, [file_name])        
    match_file_pairs(files, spec, file_name)
  end
  
  def created?
    !@created.nil?
  end
  
  def spec_files
    @files.values.select { |sf| !sf.empty? }
  end
  
  def file_is_valid?(file)
    unless File.dirname(file) =~ self.include_directories
      return false if File.dirname(file) =~ self.exclude_directories
    end
    file =~ Regexp.new(self.file_extensions.collect{|e| "\\#{e}$"}.join('|')) ? true : false
  end
  
  def glob_files_in_path(path, globs = [])
    globs = globs.collect {|g| "-name '*#{g}'"}.join(' -o ')
    @found_files = `find "#{path}" -type f \\( #{globs} \\)`.chomp.split("\n")
  end
  
  def match_file_pairs(found_files, file, match_file_name)
    file_name = File.basename(file)
    grep_res = found_files.grep(Regexp.new(match_file_name))
    
    result_file = nil
    if grep_res.size == 1
      result_file = grep_res.first
    elsif grep_res.size > 1
      result_file = match_files_by_path(file, match_file_name, grep_res)
    end
    
    return (result_file && file_is_valid?(result_file)) ? result_file : nil
  end
  
  def spec_name_from_file(file)
    if File.extname(file) == '.rb'
      File.basename(file, File.extname(file)) + "_spec#{File.extname(file)}"
    else
      File.basename(file, File.extname(file)) + "#{File.extname(file)}_spec.rb"
    end
  end
  
  def file_name_from_spec(spec)
    file_name = File.basename(spec).gsub('_spec', '')
    file_name = File.basename(file_name, '.rb') if File.basename(file_name, '.rb').include?('.')
    file_name
  end
  
  def match_files_by_path(file, spec_file_name, grep_res)
    file_parts = File.dirname(file).split('/')
    path_prefix = ''
    while !file_parts.empty?
      path_prefix = File.join(file_parts.pop, path_prefix)
      grep_res.each { |spec_file| return spec_file if spec_file.match(path_prefix + spec_file_name) }
    end        
  end
  
  def is_spec?(file)
    file =~ /_spec\.rb$/ ? true : false
  end
end