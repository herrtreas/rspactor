class Listener
  attr_accessor :stream
  
  @@callback = Proc.new do |stream, ctx, num_events, paths, marks, event_ids|
    begin
      $LOG.debug "X listener.rb:6"
      changed_files = extract_changed_files_from_paths(split_paths(paths, num_events))        
      @@spec_run_time = Time.now
      $LOG.debug "X listener.rb:9"      
      @@block_to_execute.call(changed_files)
    rescue => e
      $LOG.error "#{e.message}: #{e.backtrace.first}"
    end    
  end  
  
  def self.init(path)
    return false if already_running?
    Map.ensure(path) do
      @@listener = Listener.new(path) do |files|        
        begin
          $LOG.debug "X listener.rb:21. Files#{@files.inspect}"          
          @files_to_spec = []
          files.each do |file|
            spec_file = $map[file]
            if spec_file
              $LOG.debug spec_file
              @files_to_spec << spec_file 
            end
          end 
          $LOG.debug "X listener.rb:30: Files#{@files_to_spec.inspect}"          
          SpecRunner.run_specs_for_files(@files_to_spec) unless @files_to_spec.empty?
        rescue => e
          $LOG.error "#{e.message}: #{e.backtrace.first}"
        end        
      end
    end
    true
  end
  
  def self.already_running?
    class_variable_defined?(:@@listener)
  end
  
  def initialize(path, &block)    
    begin     
      $LOG.debug "X listener.rb:46"          
       
      @@block_to_execute = block
      @@spec_run_time = Time.now
      OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
      @stream = OSX::FSEventStreamCreate(OSX::KCFAllocatorDefault, @@callback, nil, [path], OSX::KFSEventStreamEventIdSinceNow, 0.0, 0)
      
      $LOG.debug "Listening to '#{path}'.."
      OSX::FSEventStreamScheduleWithRunLoop(@stream, OSX::CFRunLoopGetMain(), OSX::KCFRunLoopDefaultMode)
      OSX::FSEventStreamStart(@stream)

    rescue => e
      $LOG.error "#{e.message}: #{e.backtrace.first}"
      OSX::FSEventStreamStop(@stream)
      OSX::FSEventStreamInvalidate(@stream)
      OSX::FSEventStreamRelease(@stream)
    end
  end
  
  def stop
    if @stream
      OSX::FSEventStreamStop(@stream)
      OSX::FSEventStreamInvalidate(@stream)
      OSX::FSEventStreamRelease(@stream)
      @stream = nil
    end
  end
  
  def self.split_paths(paths, num_events)
    $LOG.debug "X listener.rb:73"              
    paths.regard_as('*')
    rpaths = []        
    num_events.times { |i| rpaths << paths[i] }
    $LOG.debug "X listener.rb:77"              
    rpaths    
  end
  
  def self.extract_changed_files_from_paths(paths)
    begin
      $LOG.debug "X listener.rb:83"                
      changed_files = []
      paths.each do |path|
        Dir.glob(path + "*").each do |file|
          next unless $map.file_is_valid?(file)
          file_time = File.stat(file).mtime
          changed_files << file if file_time > @@spec_run_time
        end
      end
      $LOG.debug "X listener.rb:92"                
      changed_files
    rescue => e
      $LOG.error "#{e.message}: #{e.backtrace.first}"
      []
    end
  end
  
end