module RSpactor
  module Core
    class Command
      
      def self.run_spec(locations)
        if locations.first.nil? # no specs found
          $coreInterop.notify_about_error(["No specs found."]) 
          return
        end
        
        spec_runner_bin = script_runner
        locations = locations.join(" ")
        cmd =   "RAILS_ENV=test; "
        cmd <<  "#{spec_runner_bin} "
        cmd <<  "#{locations} --loadby mtime " # --reverse 
        cmd <<  "-r #{File.dirname(__FILE__)}/remote_result.rb -f RSpactor::Core::RemoteResult:STDOUT"
        $LOG.debug cmd

        Open4.popen4("#{cmd}; echo $?") do |pid, stdin, stdout, stderr|
          @@result = stdout.readlines
          @@error = stderr.readlines
        end
      
        $coreInterop.notify_about_error(@@error.map { |e| e.strip }) unless @@error.empty?
      end
    
      def self.script_runner
        # root = file[0..file.index("spec") - 1]
        # if File.exist?(root + "script/spec")
        #   return root + "script/spec"
        # else
          "spec"
        # end
      end  
  
    end    
  end
end