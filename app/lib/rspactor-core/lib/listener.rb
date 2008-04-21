class Listener
  
  attr_accessor :stream
  
  def initialize(path, &block)    
    require 'osx/foundation'
    begin
      
      @spec_run_time = Time.now
      callback = lambda do |stream, ctx, num_events, paths, marks, event_ids|
        changed_files = extract_changed_files_from_paths(split_paths(paths, num_events))        
        @spec_run_time = Time.now
        yield changed_files
      end

      OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
      @stream = OSX::FSEventStreamCreate(OSX::KCFAllocatorDefault, callback, nil, [path], OSX::KFSEventStreamEventIdSinceNow, 0.2, 0)

      OSX::FSEventStreamScheduleWithRunLoop(@stream, OSX::CFRunLoopGetMain(), OSX::KCFRunLoopDefaultMode)
      OSX::FSEventStreamStart(@stream)

    rescue => e
      puts e.to_s
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
  
  def split_paths(paths, num_events)
    paths.regard_as('*')
    rpaths = []        
    num_events.times { |i| rpaths << paths[i] }
    rpaths    
  end
  
  def extract_changed_files_from_paths(paths)
    changed_files = []
    paths.each do |path|
      Dir.glob(path + "*").each do |file|
        next if Inspection.file_is_invalid?(file)
        file_time = File.stat(file).mtime
        changed_files << file if file_time > @spec_run_time
      end
    end
    changed_files
  end
  
end