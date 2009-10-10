require 'rspactor'

module RSpactor
  class Celerity
    
    def self.start(dir)
      pid_path = "#{dir}/tmp/pids/mongrel_celerity.pid"
      if File.exist?(pid_path)
        system("kill $(head #{pid_path}) >/dev/null 2>&1")
        system("rm #{pid_path} >/dev/null 2>&1")
      end
      # kill other mongrels
      system("kill $(ps aux | grep 'mongrel_rails' | grep -v grep | awk '//{print $2;}') >/dev/null 2>&1")
      system("rake celerity_server:start >/dev/null 2>&1 &")
      Interactor.ticker_msg "** Starting celerity server"
    end
    
    def self.restart
      system("rake celerity_server:stop >/dev/null 2>&1 && rake celerity_server:start >/dev/null 2>&1 &")
      Interactor.ticker_msg "** Restarting celerity server"
    end
    
    def self.kill_jruby
      system("kill $(ps aux | grep jruby | grep -v grep | awk '//{print $2;}') >/dev/null 2>&1")
      true
    end
    
  end
end