require 'rspactor/runner'

describe RSpactor::Runner do
  
  described_class.class_eval do
    def run_command(cmd)
      # never shell out in tests
      cmd
    end
  end
  
  def with_env(name, value)
    old_value = ENV[name]
    ENV[name] = value
    begin
      yield
    ensure
      ENV[name] = old_value
    end
  end
  
  def capture_stderr(io = StringIO.new)
    @old_stderr, $stderr = $stderr, io
    begin; yield ensure; restore_stderr; end if block_given?
  end
  
  def restore_stderr
    $stderr = @old_stderr
  end
  
  def capture_stdout(io = StringIO.new)
    @old_stdout, $stdout = $stdout, io
    begin; yield ensure; restore_stdout; end if block_given?
  end
  
  def restore_stdout
    $stdout = @old_stdout
  end
  
  it 'should use the current directory to run in' do
    mock_instance = mock('RunnerInstance')
    mock_instance.stub!(:start)
    RSpactor::Runner.should_receive(:new).with(Dir.pwd, {}).and_return(mock_instance)
    RSpactor::Runner.start
  end
  
  it 'should take an optional directory to run in' do
    mock_instance = mock('RunnerInstance')
    mock_instance.stub!(:start)
    RSpactor::Runner.should_receive(:new).with('/tmp/mu', {}).and_return(mock_instance)
    RSpactor::Runner.start(:run_in => '/tmp/mu')
  end
  
  describe "start" do
    before(:each) do
      @runner = described_class.new('/my/path')
      capture_stdout
    end
    
    after(:each) do
      restore_stdout
    end
    
    def setup
      @runner.start
    end
    
    context "Interactor" do
      before(:each) do
        @runner.stub!(:load_dotfile)
        @runner.stub!(:start_listener)
        @interactor = mock('Interactor')
        @interactor.should_receive(:start_termination_handler)
        RSpactor::Interactor.should_receive(:new).and_return(@interactor)
      end
      
      it "should start Interactor" do
        @interactor.should_receive(:wait_for_enter_key).with(instance_of(String), 2, false)
        setup
      end
      
      it "should run all specs if Interactor isn't interrupted" do
        @interactor.should_receive(:wait_for_enter_key).and_return(nil)
        @runner.should_receive(:run_spec_command).with('/my/path/spec')
        setup
      end
      
      it "should skip running all specs if Interactor is interrupted" do
        @interactor.should_receive(:wait_for_enter_key).and_return(true)
        @runner.should_not_receive(:run_spec_command)
        setup
      end
    end
    
    it "should initialize Inspector" do
      @runner.stub!(:load_dotfile)
      @runner.stub!(:start_interactor)
      RSpactor::Inspector.should_receive(:new)
      RSpactor::Listener.stub!(:new).and_return(mock('Listener').as_null_object)
      setup
    end
    
    context "Listener" do
      before(:each) do
        @runner.stub!(:load_dotfile)
        @runner.stub!(:start_interactor)
        @inspector = mock("Inspector")
        RSpactor::Inspector.stub!(:new).and_return(@inspector)
        @listener = mock('Listener')
      end
      
      it "should run Listener" do
        @listener.should_receive(:run).with('/my/path')
        RSpactor::Listener.should_receive(:new).with(instance_of(Array)).and_return(@listener)
        setup
      end
    end
  
    it "should output 'watching' message on start" do
      @runner.stub!(:load_dotfile)
      @runner.stub!(:start_interactor)
      @runner.stub!(:start_listener)
      setup
      $stdout.string.chomp.should == "** RSpactor is now watching at '/my/path'"
    end
    
    context "dotfile" do
      before(:each) do
        @runner.stub!(:start_interactor)
        @runner.stub!(:start_listener)
      end
      
      it "should load dotfile if found" do
        with_env('HOME', '/home/moo') do
          File.should_receive(:exists?).with('/home/moo/.rspactor').and_return(true)
          Kernel.should_receive(:load).with('/home/moo/.rspactor')
          setup
        end
      end
    
      it "should continue even if the dotfile raised errors" do
        with_env('HOME', '/home/moo') do
          File.should_receive(:exists?).and_return(true)
          Kernel.should_receive(:load).with('/home/moo/.rspactor').and_raise(ArgumentError)
          capture_stderr do
            lambda { setup }.should_not raise_error
            $stderr.string.split("\n").should include('Error while loading /home/moo/.rspactor: ArgumentError')
          end
        end
      end
    end
  end
  
  describe "#run_spec_command" do
    before(:each) do
      @runner = described_class.new('/my/path')
    end
    
    def with_rubyopt(string, &block)
      with_env('RUBYOPT', string, &block)
    end
    
    def run(paths)
      @runner.run_spec_command(paths)
    end
    
    it "should exit if the paths argument is empty" do
      @runner.should_not_receive(:run_command)
      run([])
    end
    
    it "should specify runner spec runner with joined paths" do
      run(%w(foo bar)).should include(' spec foo bar ')
    end
    
    it "should specify default options: --color" do
      run('foo').should include(' --color')
    end
    
    it "should setup RUBYOPT environment variable" do
      with_rubyopt(nil) do
        run('foo').should include("RUBYOPT='-Ilib:spec' ")
      end
    end
    
    it "should concat existing RUBYOPTs" do
      with_rubyopt('-rubygems -w') do
        run('foo').should include("RUBYOPT='-Ilib:spec -rubygems -w' ")
      end
    end
    
    it "should include growl formatter" do
      run('foo').should include(' --format RSpecGrowler:STDOUT')
    end
    
    it "should include 'progress' formatter" do
      run('foo').should include(' -f progress')
    end
    
    it "should not include 'progress' formatter if there already are 2 or more formatters" do
      @runner.should_receive(:spec_formatter_opts).and_return('-f foo --format bar')
      run('foo').should_not include('--format progress')
    end
    
    it "should save status of last run" do
      @runner.should_receive(:run_command).twice.and_return(true, false)
      run('foo')
      @runner.last_run_failed?.should be_false
      run('bar')
      @runner.last_run_failed?.should be_true
      run([])
      @runner.last_run_failed?.should be_false
    end
  end
  
  describe "#changed_files" do
    before(:each) do
      @runner = described_class.new('.')
      @runner.stub!(:inspector).and_return(mock("Inspector"))
    end
    
    def set_inspector_expectation(file, ret)
      @runner.inspector.should_receive(:determine_files).with(file).and_return(ret)
    end
    
    it "should find and run spec files" do
      set_inspector_expectation('moo.rb', ['spec/moo_spec.rb'])
      set_inspector_expectation('views/baz.haml', [])
      set_inspector_expectation('config/bar.yml', ['spec/bar_spec.rb', 'spec/bar_stuff_spec.rb'])
      
      expected = %w(spec/moo_spec.rb spec/bar_spec.rb spec/bar_stuff_spec.rb)
      @runner.should_receive(:run_spec_command).with(expected)
      
      capture_stdout do
        @runner.stub!(:dir)
        @runner.send(:changed_files, %w(moo.rb views/baz.haml config/bar.yml))
        $stdout.string.split("\n").should == expected
      end
    end
    
    it "should run the full suite after a run succeded when the previous one failed" do
      @runner.inspector.stub!(:determine_files).and_return(['spec/foo_spec.rb'], ['spec/bar_spec.rb'])
      @runner.stub!(:options).and_return({ :retry_failed => true })
      
      capture_stdout do
        @runner.stub!(:run_spec_command)
        @runner.should_receive(:last_run_failed?).and_return(true, false)
        @runner.should_receive(:run_all_specs)
        @runner.send(:changed_files, %w(moo.rb))
      end
    end
  end
  
  it "should have Runner in global namespace for backwards compatibility" do
    defined?(::Runner).should be_true
    ::Runner.should == described_class
  end
  
end