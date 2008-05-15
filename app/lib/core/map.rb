module RSpactor
  module Core
    class Map
      attr_accessor :root
      attr_reader   :files
      
      def self.init(path, &block)
        Thread.new do 
          $LOG.debug 'Ensuring map..' # TODO: Replace with logging mechanism
          wait_if_map_is_currently_building
          unless $map && $map.created?
            $LOG.debug "Rebuild map in #{path}.." # TODO: Replace with logging mechanism
            $map = Map.new
            $map.root = path
            $map.create
          end
          yield if block_given?
        end
      end
      
      def self.wait_if_map_is_currently_building
        return unless defined?(@@creating_map) || (defined?(@@creating_map) && @@creating_map == true)
        while @@creating_map == true
          sleep 0.1
        end
      end
      
      def initialize
        @files = {}
      end
      
      def create
        lock_during_map_creation do
          @files = {}
          @found_files = []
          glob_files_in_path(@root, %w(vendor .git))
          @found_files.each do |f|
            next if p =~ /_spec.rb$/          
            spec_file = spec_for_file(@found_files, f)
            @files[f] = spec_file if spec_file
          end
          @created = true
        end
      end
      
      def lock_during_map_creation(&block)
        @@creating_map = true
        yield
        @@creating_map = false
      end
      
      def [](file)
        return file if is_spec?(file)
        @files[file]
      end
      
      def created?
        !@created.nil?
      end
      
      def spec_files
        @files.values
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
      
      def is_spec?(file)
        file =~ /_spec\.rb$/ ? true : false
      end
    end
  end
end