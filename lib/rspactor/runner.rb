require 'rspactor'

module RSpactor
  class Runner
    def self.start(options = {})
      run_in = options.delete(:run_in) || Dir.pwd
      new(run_in, options).start
    end
    
    attr_reader :dir, :options, :inspector, :interactor
    
    def initialize(dir, options = {})
      @dir = dir
      @options = options
      read_git_head
    end
    
    def start
      load_dotfile
      puts "** RSpactor is now watching at '#{dir}'"
      Spork.start if options[:spork]
      Celerity.start(dir) if options[:celerity]
      start_interactor
      start_listener
    end
    
    def start_interactor
      @interactor = Interactor.new(self)
      aborted = @interactor.wait_for_enter_key("** Hit <enter> to skip initial spec & cucumber run", 2, false)
      @interactor.start_termination_handler
      unless aborted
        run_all_specs
        run_cucumber_command('~@wip,~@pending', false)
      end
    end
    
    def start_listener
      @inspector = Inspector.new(self)
      
      Listener.new(Inspector::EXTENSIONS) do |files|
        changed_files(files) unless git_head_changed?
      end.run(dir)
    end
    
    def load_dotfile
      dotfile = File.join(ENV['HOME'], '.rspactor')
      if File.exists?(dotfile)
        begin
          Kernel.load dotfile
        rescue => e
          $stderr.puts "Error while loading #{dotfile}: #{e}"
        end
      end
    end
    
    def run_all_specs
      run_spec_command(File.join(dir, 'spec'))
    end
    
    def run_spec_command(paths)
      paths = Array(paths)
      if paths.empty?
        @last_run_failed = nil
      else
        cmd = [ruby_opts, spec_runner, paths, spec_opts].flatten.join(' ')
        @last_run_failed = run_command(cmd)
      end
    end
    
    def run_cucumber_command(tags = '@wip:2', clear = @options[:clear])
      system("clear;") if clear
      puts "** Running all #{tags} tagged features..."
      cmd = [ruby_opts, cucumber_runner, cucumber_opts(tags)].flatten.join(' ')
      @last_run_failed = run_command(cmd)
      # Workaround for killing jruby process when used with celerity and spork
      Celerity.kill_jruby if options[:celerity] && options[:spork]
    end
    
    def last_run_failed?
      @last_run_failed == false
    end
    
    protected
    
    def run_command(cmd)
      system(cmd)
      $?.success?
    end
    
    def changed_files(files)
      files = files.inject([]) do |all, file|
        all.concat inspector.determine_files(file)
      end
      unless files.empty?
        
        # cucumber features
        if files.delete('cucumber')
          run_cucumber_command
        end
        
        # specs files
        unless files.empty?
          system("clear;") if @options[:clear]
          files.uniq!
          puts files.map { |f| f.to_s.gsub(/#{dir}/, '') }.join("\n")
          
          previous_run_failed = last_run_failed?
          run_spec_command(files)
          
          if options[:retry_failed] and previous_run_failed and not last_run_failed?
            run_all_specs
          end
        end
      end
    end
    
    private
    
    def spec_opts
      if File.exist?('spec/spec.opts')
        opts = File.read('spec/spec.opts').gsub("\n", ' ')
      else
        opts = "--color"
      end
      
      opts << spec_formatter_opts
      # only add the "progress" formatter unless no other (besides growl) is specified
      opts << ' -f progress' unless opts.scan(/\s(?:-f|--format)\b/).length > 1
      
      opts
    end
    
    def cucumber_opts(tags)
      if File.exist?('features/support/cucumber.opts')
        opts = File.read('features/support/cucumber.opts').gsub("\n", ' ')
      else
        opts = "--color --format progress --drb --no-profile"
      end
      
      opts << " --tags #{tags}"
      opts << cucumber_formatter_opts
      opts << " --require features" # because using require option overwrite default require
      opts << " features"
      opts
    end
    
    def spec_formatter_opts
      " --require #{File.dirname(__FILE__)}/../rspec_growler.rb --format RSpecGrowler:STDOUT"
    end
    
    def cucumber_formatter_opts
      " --require #{File.dirname(__FILE__)}/../cucumber_growler.rb"
    end
    
    def spec_runner
      if File.exist?("script/spec")
        "script/spec"
      else
        "spec"
      end
    end
    
    def cucumber_runner
      if File.exist?("script/cucumber")
        "script/cucumber"
      else
        "cucumber"
      end
    end
    
    def ruby_opts
      other = ENV['RUBYOPT'] ? " #{ENV['RUBYOPT']}" : ''
      other << ' -rcoral' if options[:coral]
      %(RUBYOPT='-Ilib:spec#{other}')
    end
    
    def git_head_changed?
      old_git_head = @git_head
      read_git_head
      @git_head and old_git_head and @git_head != old_git_head
    end
    
    def read_git_head
      git_head_file = File.join(dir, '.git', 'HEAD')
      @git_head = File.exists?(git_head_file) && File.read(git_head_file)
    end
  end
end

# backward compatibility
Runner = RSpactor::Runner