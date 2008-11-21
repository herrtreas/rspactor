module SpecRunner
  class << self
    attr_accessor :queue
    
    def init
      self.queue = RunnerQueue.new
    end
    
    def run_in_path(path)
      if $app.root and $app.root != path
        ExampleFiles.clear!
        $app.post_notification(:map_location_changed)         
      end
      
      $app.root = path.to_s
      run_all_specs_in_path
    end
    
    def run_all_specs_in_path
      self.queue << File.join($app.root, 'spec/')
      process_queue
    end
    
    def run_specs_for_files(files)
      return false if files.empty?            # TODO: Notify user
      self.queue.add_bulk(files)
      process_queue
    end
    
    def process_queue
      return false if command_running?      
      unless self.queue.empty?
        $app.post_notification :spec_run_invoked
        run_command(create_runner_arguments(self.queue.next_files))
      end
    end
    
    def create_runner_arguments(locations)
      args = locations
      args << "--require=#{File.dirname(__FILE__)}/rspactor_formatter.rb"
      args << "-fRSpactorFormatter:STDOUT"
      args << '-Lmtime'
      args << '--reverse'
      args
    end
    
    def command_running?
      defined?(@@command_running) && @@command_running == true
    end
    
    def commandFinished?
      !command_running?
    end
    
    def commandHasFinished!
      @@command_running = false
      process_queue
    end
    
    def run_command(args)
      return false if command_running?
      @@command_running = true
      
      runner, args = prepare_running_environment(args)
      $LOG.debug "Running: #{runner} with #{args.inspect}.."
      task = OSX::NSTask.alloc.init
      
      output_pipe = OSX::NSPipe.alloc.init
      error_pipe = OSX::NSPipe.alloc.init
      task.standardOutput = output_pipe
      task.standardError = error_pipe

      task.arguments = args
      task.launchPath = runner
      task.launch
      
      $output_pipe_handle = output_pipe.fileHandleForReading
      $error_pipe_handle = error_pipe.fileHandleForReading
      $output_pipe_handle.readInBackgroundAndNotify
      $error_pipe_handle.readInBackgroundAndNotify
      
      $raw_output.unshift([Time.now, ''])      
      true
    end

    def prepare_running_environment(args)
      if File.exist?(File.join($app.root, 'script/spec'))
        runner = "#{$app.default_from_key(:ruby_bin_path).chomp.strip}"
        args = args.unshift "#{$app.root}/script/spec"
        [runner, args]
      else
        [$app.default_from_key(:spec_bin_path).chomp.strip, args]
      end
    end
    
  end
end