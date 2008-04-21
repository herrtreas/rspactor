module RSpactor
  module Core
    class Spec
  
      attr_accessor :state
      attr_accessor :name, :example_group_name
      attr_accessor :message
      attr_accessor :error_header, :error_type, :error_line, :error_file, :backtrace
  
      def initialize(opts = {})
        opts.each { |key, value| self.send("#{key.to_s}=".intern, value) }
      end
  
      def to_s
        "#{@example_group_name} #{@name}"
      end
      
      def backtrace=(trace)
        @backtrace = trace
        @error_line = trace[0].split(":").last
        @error_file = trace[0].split("/").last.split(":").first
      end
      
    end
  end
end
