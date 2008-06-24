class SpecFile
  attr_accessor :full_path, :name
  attr_accessor :specs
  
  def initialize(opts = {})
    @specs = []
    opts.each { |key, value| self.send("#{key.to_s}=".intern, value) } rescue true
  end
  
  def name    
    File.basename(@full_path) if @full_path
  end
  
  def <<(spec)    
    @specs << spec unless contains_spec?(spec)
  end
  
  def spec_count
    @specs.count
  end
  
  def contains_spec?(spec)
    !@specs.select { |s| s.to_s == spec.to_s }.empty?
  end
end