class RunnerQueue
  def initialize
    @queue = []
  end
  
  def <<(path)
    @queue << path
    @queue.uniq!
  end
  
  def add_bulk(files)
    @queue += files
    @queue.uniq!
  end
  
  def size
    @queue.size
  end
  
  def empty?
    @queue.size == 0
  end
  
  def next_files
    files = @queue.clone
    @queue.clear
    files
  end
end