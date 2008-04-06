class Runner
  
  def self.load
    @inspector  = Inspector.new
    @interactor = Interactor.new

    puts "** RSpactor is now watching at '#{Dir.pwd}'"
    
    if initial_spec_run_abort   
      @interactor.start_termination_handler
    else
      @interactor.start_termination_handler
      run_all_specs 
    end
    
    Listener.new do |files|
      files_to_spec = []
      files.each do |file|
        spec_file = @inspector.find_spec_file(file)
        if spec_file
          puts spec_file
          files_to_spec << spec_file 
        end
      end  
      run_spec_command(files_to_spec) unless files_to_spec.empty?
    end
  end

  def self.run_all_specs
    run_spec_command([@inspector.inner_spec_directory(Dir.pwd)])
  end

  def self.run_specs_for_files(files, verbose = false)
    files_to_spec = []
    files.each do |file|
      spec_file = @inspector.find_spec_file(file)
      if spec_file
        puts spec_file if verbose
        files_to_spec << spec_file 
      end
    end  
    run_spec_command(files_to_spec) unless files_to_spec.empty?
  end

  def self.run_spec_command(locations)
    base_spec_root  = extract_spec_root(locations.first)
    spec_runner_bin = script_runner(locations.first)
    locations = locations.join(" ")
    cmd =   "RAILS_ENV=test; "
    cmd <<  "#{spec_runner_bin} "
    cmd <<  "#{locations} #{spec_opts(base_spec_root)} "
    cmd <<  "-r #{File.dirname(__FILE__)}/../lib/resulting.rb -f RSpactorFormatter:STDOUT"
    #puts cmd
    system(cmd)
  end
  
  def self.extract_spec_root(file)
    file[0..file.index("spec") + 4]
  end
  
  def self.spec_opts(base_spec_root)
    if File.exist?("#{base_spec_root}spec.opts")
      return "-O #{base_spec_root}spec.opts"
    else
      return "-c -f progress"
    end
  end
  
  def self.initial_spec_run_abort
    @interactor.wait_for_enter_key("** Hit <enter> to skip initial spec run", 3)
  end
  
  def self.script_runner(file)
    root = file[0..file.index("spec") - 1]
    if File.exist?(root + "script/spec")
      return root + "script/spec"
    else
      "spec"
    end
  end
end