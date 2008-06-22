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
end