module SpecRunner
  class << self
    attr_accessor :task
    attr_accessor :queue
    attr_accessor :current_job
    
    def init
      self.queue = RunnerQueue.new
    end
    
    def run_job(job)
      root_location_has_changed?(job)
      self.queue.add_bulk(job.paths)
      self.current_job = job
      process_queue
    end
    
    def root_location_has_changed?(job)
      if $app.root and $app.root != job.root
        ExampleFiles.clear!
        $app.post_notification(:map_location_changed)         
      end
      $app.root = job.root      
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
      args << '-L=mtime'
#      args << '--drb'
      args
    end
    
    def command_running?
      defined?(@@command_running) && @@command_running == true
    end
    
    def commandFinished?
      !command_running?
    end
    
    def commandAbortedByHand?
      defined?(@@command_manually_aborted) && @@command_manually_aborted == true
    end
    
    def commandHasFinished!
      @@command_running = false
      process_queue
    end
    
    def run_command(args)
      return false if command_running?
      
      $app.post_notification :example_run_global_start
      
      @@command_running = true
      @@command_manually_aborted = false
      
      runner, args = prepare_running_environment(args)
      $LOG.debug "Running: #{runner} with #{args.inspect}.."
      @task = OSX::NSTask.alloc.init
      
      output_pipe = OSX::NSPipe.alloc.init
      error_pipe = OSX::NSPipe.alloc.init
      @task.standardOutput = output_pipe
      @task.standardError = error_pipe

      @task.arguments = args
      @task.launchPath = runner
      @task.launch
      
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
    
    def terminate_current_task
      return unless @task
      return unless @task.isRunning
      @@command_manually_aborted = true
      @task.terminate
    end    
  end
end