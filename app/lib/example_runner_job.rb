class ExampleRunnerJob
  attr_accessor :paths
  attr_accessor :root
  attr_accessor :hide_growl_messages_for_failed_examples
  
  def initialize(opts = {})
    self.paths = opts.delete(:paths)
    self.root  = opts.delete(:root)
  end
  
  def paths
    if @paths && !@paths.empty?
      @paths
    else
      [File.join(@root, 'spec/')]
    end
  end
  
  def root
    @root ? @root : $app.root
  end
end