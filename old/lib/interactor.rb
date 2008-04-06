require 'timeout'

class Interactor
  
  def initialize
    ticker
  end
  
  def wait_for_enter_key(msg, seconds_to_wait)
    begin
      Timeout::timeout(seconds_to_wait) do
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
        if $stdin.gets
          if wait_for_enter_key("** Running all specs.. Hit <enter> again to exit RSpactor", 3)
            @main_thread.exit 
            exit
          end
          Runner.run_all_specs
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
