require 'timeout'

module RSpactor
  class Interactor
    
    attr_reader :runner
    
    def initialize(runner)
      @runner = runner
      ticker
    end
    
    def self.ticker_msg(msg, seconds_to_wait = 3)
      $stdout.print msg
      seconds_to_wait.times do
        $stdout.print('.')
        $stdout.flush
        sleep 1
      end
      $stdout.puts "\n"
    end
    
    def wait_for_enter_key(msg, seconds_to_wait, clear = runner.options[:clear])
      begin
        Timeout::timeout(seconds_to_wait) do
          system("clear;") if clear
          ticker(:start => true, :msg => msg)
          $stdin.gets
          return true
        end
      rescue Timeout::Error
        false
      ensure
        ticker(:stop => true)
      end
    end
    
    def start_termination_handler
      @main_thread = Thread.current
      Thread.new do
        loop do
          sleep 0.5
          if entry = $stdin.gets
            case entry
            when "c\n" # Cucumber: current tagged feature
              runner.run_cucumber_command
            when "ca\n" # Cucumber All: ~pending tagged feature
              runner.run_cucumber_command('~@wip,~@pending')
            else
              if wait_for_enter_key("** Running all specs... Hit <enter> again to exit RSpactor", 1)
                @main_thread.exit
                exit
              end
              runner.run_all_specs
            end
          end
        end
      end
    end
    
    private
    
    def ticker(opts = {})
      if opts[:stop]
        $stdout.puts "\n"
        @pointer_running = false
      elsif opts[:start]
        @pointer_running = true
        write(opts[:msg]) if opts[:msg]
      else
        Thread.new do
          loop do
            write('.') if @pointer_running == true
            sleep 1.0
          end
        end
      end
    end
    
    def write(msg)
      $stdout.print(msg)
      $stdout.flush
    end
  end
end