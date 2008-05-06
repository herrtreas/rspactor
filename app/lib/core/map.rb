module RSpactor
  module Core
    class Map
      attr_accessor :root
      attr_reader   :files
      
      def initialize
        @files = {}
      end
      
      def create
        found_files = Dir.glob(File.join(@root, "**", "*.{rb,haml,erb}"))
        found_files.each do |f|
          next if f.match(/_spec.rb/)
          spec_file = spec_for_file(found_files, f)
          @files[f] = spec_file if spec_file
        end      
      end
      

      private
      
      def spec_for_file(found_files, file)
        file_name = File.basename(file)
        spec_file_name = spec_name_from_file(file)
        puts spec_file_name
        grep_res = found_files.grep(Regexp.new(spec_file_name))
        if grep_res.size == 1
          return grep_res.first
        else
          return match_spec_files_by_path(file, spec_file_name, grep_res)
        end
      end
      
      def spec_name_from_file(file)
        if File.extname(file) == '.rb'
          File.basename(file, File.extname(file)) + "_spec#{File.extname(file)}"
        else
          File.basename(file, File.extname(file)) + "#{File.extname(file)}_spec.rb"
        end
      end
      
      def match_spec_files_by_path(file, spec_file_name, grep_res)
        file_parts = File.dirname(file).split('/')
        path_prefix = ''
        while !file_parts.empty?
          path_prefix = File.join(file_parts.pop, path_prefix)
          grep_res.each { |spec_file| return spec_file if spec_file.match(path_prefix + spec_file_name) }
        end        
      end
      
    end
  end
end