module RSpactor
  module Core
    class Runtime
  
      def self.listen(path)
        self.stop_listening
        return unless File.exist?(path)
        
        $LOG.debug "RSpactor is listening to '#{path}'"
        @@listener = Listener.new(path) do |files|
          begin
            @files_to_spec = []
            files.each do |file|
              spec_file = $map[file]
              if spec_file
                $LOG.debug spec_file
                @files_to_spec << spec_file 
              end
            end 
            Thread.new { Command.run_spec(@files_to_spec) unless @files_to_spec.empty? }
          rescue => e
            $LOG.error "#{e.message}: #{e.backtrace.first}"
          end
        end

      end
      
      def self.stop_listening
        if defined?(@@listener)
          @@listener.stop 
        end
      end

      def self.run_all_specs_in_path(path)
        return unless File.exist?(path)
        self.stop_listening
        Thread.new { Command.run_spec([$map.spec_files]) }
      end     
      
    end    
  end
end