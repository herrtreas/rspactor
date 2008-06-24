class SpecList
  attr_accessor :total_spec_count
  attr_accessor :processed_spec_count
  attr_accessor :filter
  
  def initialize
    @filter = :all
    @list = []
    @files = []
    @processed_spec_count = 0
  end
  
  def << (spec)
    add_or_replace(spec)
    add_or_update_file(spec)
  end

  def [] (index)
    @list[index]
  end

  def index(obj)
    @list.index(obj)
  end

  def at(obj)
    @list.at(obj)
  end
    
  def clear_run_stats
    @total_spec_count = 0
    @processed_spec_count = 0
    @list = []
  end

  def size
    files.size
  end

  def files
    filter_by(@filter)
  end

  def filter_by(type = :all)
    return @files if type == :all
    filter_list_by(type)
  end
  
  def file_by_index(index)
    files[index]
  end
  
  def contains_file?(file)
    !files.select { |f| f.full_path == file.full_path}.empty?
  end  
    
  def file_by_path(path)
    @files.select { |f| f.full_path == path}.first
  end
  
  def file_by_spec(spec)  
    file_by_path(spec.full_file_path)
  end
  
  def index_by_file(file)
    index = 0
    files.each do |f|
      return index if f.full_path == file.full_path
      index += 1
    end
  end
  
  def index_by_spec(spec)
    index_by_file(file_by_spec(spec))
  end
  
  private

    def filter_list_by(type)
      @files.select do |file|
        !file.specs.select {|spec| spec.state == type }.empty?
      end
    end
    
    def add_or_update_file(spec)
      spec_file = file_by_path(spec.full_file_path)
      unless spec_file
        spec_file = SpecFile.new(:full_path => spec.full_file_path)
        @files << spec_file
      end
      spec_file << spec
    end
    
    def add_or_replace(spec)
      old_spec = @list.select {|s| s.to_s == spec.to_s}.first
      if old_spec
        @list[@list.index(old_spec)] = spec
      else
        @list << spec
      end
    end
end