require 'rspactor'

module RSpactor
  class Spork
    
    def self.start
      kill_and_launch
      Interactor.ticker_msg "** Launching Spork for rspec & cucumber"
    end
    
    def self.reload
      kill_and_launch
      Interactor.ticker_msg "** Reloading Spork for rspec & cucumber"
    end
    
  private
    
    def self.kill_and_launch
      system("kill $(ps aux | awk '/spork/&&!/awk/{print $2;}') >/dev/null 2>&1")
      system("spork >/dev/null 2>&1 < /dev/null &")
      system("spork cu >/dev/null 2>&1 < /dev/null &")
    end
    
  end
end
