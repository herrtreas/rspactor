module RSpactor
  module Core
    class Spec
  
      attr_accessor :state
      attr_accessor :name, :example_group_name
      attr_accessor :error_header, :error_message, :error_type, :backtrace
  
      def initialize(opts = {})
        opts.each { |key, value| self.send("#{key.to_s}=".intern, value) }
      end
  
      def to_s
        "#{@example_group_name} #{@name}"
      end
      
      def description
        [@error_header, @error_message, '', @backtrace.join("\n")].join("\n")
      end
      
    end
  end
end
