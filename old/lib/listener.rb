# Some code borrowed from http://rails.aizatto.com/2007/11/28/taming-the-autotest-beast-with-fsevents/

class Listener
  
  def initialize(&block)
    require 'osx/foundation'
    begin
      @spec_run_time = Time.now
      callback = lambda do |stream, ctx, num_events, paths, marks, event_ids|
        changed_files = extract_changed_files_from_paths(split_paths(paths, num_events))        
        @spec_run_time = Time.now
        yield changed_files
      end

      OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
      stream = OSX::FSEventStreamCreate(OSX::KCFAllocatorDefault, callback, nil, [Dir.pwd], OSX::KFSEventStreamEventIdSinceNow, 0.5, 0)
      unless stream
        puts "Failed to create stream"
        exit
      end

      OSX::FSEventStreamScheduleWithRunLoop(stream, OSX::CFRunLoopGetCurrent(), OSX::KCFRunLoopDefaultMode)
      unless OSX::FSEventStreamStart(stream)
        puts "Failed to start stream"
        exit 
      end

      OSX::CFRunLoopRun()
    rescue Interrupt
      OSX::FSEventStreamStop(stream)
      OSX::FSEventStreamInvalidate(stream)
      OSX::FSEventStreamRelease(stream)
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
        next if Inspector.file_is_invalid?(file)
        file_time = File.stat(file).mtime
        changed_files << file if file_time > @spec_run_time
      end
    end
    changed_files
  end
  
end