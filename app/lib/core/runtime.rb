module RSpactor
  module Core
    class Runtime
  
      def self.listen(path)
        self.stop_listening
        return unless File.exist?(path)
        
        $LOG.debug "RSpactor is listening to '#{path}'"
        @inspector  = Inspection.new
        
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
        Thread.new { Command.run_spec([Inspection.new.inner_spec_directory(path)]) }
      end


      # Not refactored yet
      def self.run_specs_for_files(files, verbose = false)
        files_to_spec = []
        files.each do |file|
          spec_file = @inspector.find_spec_file(file)
          if spec_file
            $LOG.debug spec_file if verbose
            files_to_spec << spec_file 
          end
        end  
        run_spec_command(files_to_spec) unless files_to_spec.empty?
      end
      
    end
    
  end
end