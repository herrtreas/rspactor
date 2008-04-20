module RSpactor
  module Core
    class Runtime
  
      def self.listen(path)
        self.stop_listening
        return unless File.exist?(path)
        
        puts "RSpactor is now watching at '#{path}'"
        @inspector  = Inspection.new
        
        @@listener = Listener.new(path) do |files|
          @files_to_spec = []
          files.each do |file|
            spec_file = @inspector.find_spec_file(file)
            if spec_file
              puts spec_file
              @files_to_spec << spec_file 
            end
          end 
          Thread.new { Command.run_spec(@files_to_spec) unless @files_to_spec.empty? }
        end

      end
      
      def self.stop_listening
        @@listener.stop if defined?(@@listener)
      end

      def self.run_all_specs_in_path(path)
        return unless File.exist?(path)
        Thread.new { Command.run_spec([Inspection.new.inner_spec_directory(path)]) }
      end


      # Not refactored yet
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
      
    end
    
  end
end