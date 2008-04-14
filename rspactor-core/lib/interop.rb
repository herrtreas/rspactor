module RSpactor
  module Core
    class Interop
  
      attr_accessor :change_location
      attr_accessor :command_error              # error_message
      attr_accessor :ping
    
      attr_accessor :spec_run_start             # example_count
      attr_accessor :spec_run_example_passed
      attr_accessor :spec_run_example_pending
      attr_accessor :spec_run_example_failed    # spec (RSpactor::Core::Spec)
      attr_accessor :spec_run_dump_summary      # duration, example_count, failure_count, pending_count
      attr_accessor :spec_run_close
      
  
      def initialize
        @local_service = LocalService.new(self)
      end
      
      def start_listen(path)
        Runtime.listen(path)
      end
      
      def stop_listen
        Runtime.stop_listening
      end
      
      def run_specs_in_path(path)
        stop_listen # Make sure, that the listener is disabled (otherwise we will get seg faults)
        puts "Running specs in #{path}"
        Runtime.run_all_specs_in_path(path)
      end
      
    end
  end
end