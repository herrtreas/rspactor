require 'rspactor'
require 'socket'

module RSpactor
  class Spork
    RSPEC_PORT    = 8989
    CUCUMBER_PORT = 8990
    
    attr_accessor :use_cucumber
    
    def initialize(runner)
      @use_cucumber = File.exist?(File.join(runner.dir, 'features'))
    end
    
    def start
      execute(:start)
    end
    
    def reload
      execute(:reload)
    end
    
  private
  
    def execute(start_or_reload)
      action_message = (start_or_reload == :start) ? "Starting" : "Reloading"
      message = "** #{action_message} Spork for rspec"
      message += " & cucumber" if use_cucumber
      kill_and_launch(message)
    end
    
    def kill_and_launch(message)
      Interactor.ticker_msg message do
      
        system("kill $(ps aux | awk '/spork/&&!/awk/{print $2;}') >/dev/null 2>&1")
      
        system("spork >/dev/null 2>&1 < /dev/null &")
        wait_for('RSpec', RSPEC_PORT)
      
        if use_cucumber
          system("spork cu >/dev/null 2>&1 < /dev/null &")
          wait_for('Cucumber', CUCUMBER_PORT)
        end
      
      end
    end
    
    def wait_for(sporker, port)
      15.times do
        begin
          TCPSocket.new('localhost', port).close
        rescue Errno::ECONNREFUSED
          sleep(1)
          next
        end

        return true
      end
      
      raise "could not load spork for #{sporker}; make sure you can use it manually first"
    end
    
  end
  
end
