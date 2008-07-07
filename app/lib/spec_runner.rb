module SpecRunner
  class << self
    def run_in_path(path)
      Map.ensure(path) do
        run_all_specs_in_path
      end
    end
    
    def run_all_specs_in_path
      return false if $map.spec_files.empty?  # TODO: Notify user
      run_command(create_runner_arguments($map.spec_files))
    end
    
    def run_specs_for_files(files)
      return false if files.empty?            # TODO: Notify user
      return false if command_running?      
      $app.post_notification :spec_run_invoked
      run_command(create_runner_arguments(files))
    end
    
    def create_runner_arguments(locations)
      args = locations
      args << '-Lmtime'
      args << "-r#{File.dirname(__FILE__)}/rspactor_formatter.rb"
      args << "-fRSpactorFormatter:STDOUT"
      args
    end
    
    def command_running?
      defined?(@@command_running) && @@command_running == true
    end
    
    def commandHasFinished!
      @@command_running = false
    end
    
    def run_command(args)
      return false if command_running?
      @@command_running = true
      
      runner, args = prepare_running_environment(args)
      $LOG.debug "Running: #{runner} with #{args.inspect}.."
      pipe = OSX::NSPipe.alloc.init
      task = OSX::NSTask.alloc.init
      task.standardError = pipe
      task.arguments = args
      task.launchPath = runner
      task.launch
    
      true
    end
    
    def prepare_running_environment(args)
      if File.exist?(File.join($map.root, 'script/spec'))
        runner = "#{$app.default_from_key(:ruby_bin_path).strip}"
        args = args.unshift "#{$map.root}/script/spec"
        [runner, args]
      else
        [$app.default_from_key(:spec_bin_path).strip, args]
      end
    end
    
  end
end