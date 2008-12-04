class Listener
  attr_accessor :stream
  attr_accessor :observation_list
  
  @@callback = Proc.new do |stream, ctx, num_events, paths, marks, event_ids|
    begin
      changed_files = extract_changed_files_from_paths(split_paths(paths, num_events))        
      ExampleFiles.clear_suicided_files!
      @@spec_run_time = Time.now
      @@block_to_execute.call(changed_files)
    rescue => e
      $LOG.error "#{e.message}: #{e.backtrace.first}"
    end    
  end  
  
  def self.init(path)
    if already_running?
      if class_variable_defined?(:@@listen_to_path) && @@listen_to_path != path
        @@listener.stop
      else
        return false 
      end
    end
    
    @@listener = Listener.new(path) do |files|        
      begin
        @files_to_spec = []
        files.each do |file|
          spec_file = ExampleFiles.find_example_for_file(file)
          @files_to_spec << spec_file if spec_file          
          @files_to_spec += Listener.specs_for_observed_file(file).collect { |s| s.full_file_path } if Listener.file_covered_by_observation?(file)
        end
        SpecRunner.run_job(ExampleRunnerJob.new(:paths => @files_to_spec)) unless @files_to_spec.empty?
      rescue => e
        $LOG.error "#{e.message}: #{e.backtrace.first}"
      end        
    end
    true
  end
  
  def self.already_running?
    class_variable_defined?(:@@listener)
  end
  
  def initialize(path, &block)    
    begin     
      @@block_to_execute = block
      @@spec_run_time = Time.now
      @@listen_to_path = path
      
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
    paths.regard_as('*')
    rpaths = []        
    num_events.times { |i| rpaths << paths[i] }
    rpaths    
  end
  
  def self.extract_changed_files_from_paths(paths)
    begin
      changed_files = []
      paths.each do |path|
        Dir.glob(path + "*").each do |file|
          next unless ExampleMatcher.file_is_valid?(file)
          file_time = File.stat(file).mtime
          changed_files << file if file_time > @@spec_run_time
        end
      end
      changed_files
    rescue => e
      $LOG.error "#{e.message}: #{e.backtrace.first}"
      []
    end
  end
  
  
  def self.add_request_to_observation_list(notification)
    file, spec = notification.userInfo
    file = File.expand_path(file)
    @@observation_list ||= {}
    @@observation_list[file] ||= []
    if @@observation_list[file].select { |s| s.full_file_path == spec.full_file_path }.empty?
      @@observation_list[file] << spec    
    end
  end
  
  def self.observation_list
    @@observation_list
  end
  
  def self.file_covered_by_observation?(file)
    defined?(@@observation_list) && @@observation_list[file] ? true : false
  end
  
  def self.specs_for_observed_file(file)
    @@observation_list[file]
  end
  
  def self.reset_observation_list
    @@observation_list.clear if defined?(@@observation_list)
  end
end