module SpecRunner
  class << self
    def run_in_path(path)
      $app.root = path.to_s
      run_all_specs_in_path
    end
    
    def run_all_specs_in_path
      run_command(create_runner_arguments([File.join($app.root, 'spec/')]))
    end
    
    def run_specs_for_files(files)
      return false if files.empty?            # TODO: Notify user
      return false if command_running?      
      $app.post_notification :spec_run_invoked
      run_command(create_runner_arguments(files))
    end
    
    def create_runner_arguments(locations)
      args = locations
      args << "--require=#{File.dirname(__FILE__)}/rspactor_formatter.rb"
      args << "-fRSpactorFormatter:STDOUT"
      args << '-Lmtime'
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