module RSpactor
  module Core
    class Interop
  
      attr_accessor :rebuild_map
      attr_accessor :command_error              # error_message
      attr_accessor :ping
    
      attr_accessor :spec_run_start             # example_count
      attr_accessor :spec_run_example_passed    # spec (RSpactor::Core::Spec)
      attr_accessor :spec_run_example_pending   # spec (RSpactor::Core::Spec)
      attr_accessor :spec_run_example_failed    # spec (RSpactor::Core::Spec)
      attr_accessor :spec_run_dump_summary      # duration, example_count, failure_count, pending_count
      attr_accessor :spec_run_close
      
  
      def initialize
        @local_service = LocalService.new(self)
      end
      
      def start_listen(path)
        stop_listen
        Map.init(path) do
          Runtime.listen(path)
        end
      end
      
      def stop_listen
        Runtime.stop_listening
      end
      
      def run_specs_in_path(path)
        Map.init(path) do
          stop_listen # Make sure, that the listener is disabled (otherwise we will get seg faults)
          $LOG.debug "Running specs in #{path}"
          Runtime.run_all_specs_in_path(path)
        end
      end
      
      def notify_about_error(error_message)
        command_error.call(error_message) unless $coreInterop.command_error.nil?
      end      
    end
  end
end