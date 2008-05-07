module RSpactor
  module Core
    class Map
      attr_accessor :root
      attr_reader   :files
      
      def initialize
        @files = {}
      end
      
      def create
        @found_files = []
        glob_files_in_path(@root, %w(vendor .git))
        @found_files.each do |f|
          next if p =~ /_spec.rb$/          
          spec_file = spec_for_file(@found_files, f)
          @files[f] = spec_file if spec_file
        end      
      end
      
      def [](file)
        @files[file]
      end

      
      private
    
      def glob_files_in_path(path, exclude)
        Dir.entries(path).each do |p|
          next if p == '.' || p == '..'
          p = File.join(path, p)          
          if File.directory?(p)
            next if p =~ Regexp.new(exclude.join('|'))
            glob_files_in_path(p, exclude)
          else
            next unless p =~ /\.rb$|\.erb$|\.haml$/
            @found_files << p
          end
        end
      end
      
      def spec_for_file(found_files, file)
        file_name = File.basename(file)
        spec_file_name = spec_name_from_file(file)
        grep_res = found_files.grep(Regexp.new(spec_file_name))
        if grep_res.size == 1
          return grep_res.first
        elsif grep_res.size > 1
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
      
      def run_to_top_and_try_finding_spec_for_file(file)
        spec_to_find = spec_name_from_file(file)
      end
    end
  end
end