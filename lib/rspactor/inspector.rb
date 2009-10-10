require 'rspactor'

module RSpactor
  # Maps the changed filenames to list of specs to run in the next go.
  # Assumes Rails-like directory structure
  class Inspector
    EXTENSIONS = %w(rb erb builder haml rhtml rxml yml conf opts feature)
    
    attr_reader :runner, :root
    
    def initialize(runner)
      @runner = runner
      @root = runner.dir
    end
    
    def determine_files(file)
      candidates = translate(file)
      cucumberable = candidates.delete('cucumber')
      candidates.reject { |candidate| candidate.index('.') }.each do |dir|
        candidates.reject! { |candidate| candidate.index("#{dir}/") == 0 }
      end
      files = candidates.select { |candidate| File.exists? candidate }
      
      if files.empty? && !candidates.empty? && !cucumberable 
        $stderr.puts "doesn't exist: #{candidates.inspect}"
      end
      
      files << 'cucumber' if cucumberable
      files
    end
    
    # mappings for Rails are inspired by autotest mappings in rspec-rails
    def translate(file)
      file = file.sub(%r:^#{Regexp.escape(root)}/:, '')
      candidates = []
      
      if spec_file?(file)
        candidates << file
      elsif cucumber_file?(file)
        candidates << 'cucumber'
      else
        spec_file = append_spec_file_extension(file)
        
        case file
        when %r:^app/:
          if file =~ %r:^app/controllers/application(_controller)?.rb$:
            candidates << 'controllers'
          elsif file == 'app/helpers/application_helper.rb'
            candidates << 'helpers' << 'views'
          elsif !file.include?("app/views/") || runner.options[:view]
            candidates << spec_file.sub('app/', '')
            
            if file =~ %r:^app/(views/.+\.[a-z]+)\.[a-z]+$:
              candidates << append_spec_file_extension($1)
            elsif file =~ %r:app/helpers/(\w+)_helper.rb:
              candidates << "views/#{$1}"
            elsif file =~ /_observer.rb$/
              candidates << candidates.last.sub('_observer', '')
            end
          end
        when %r:^lib/:
          candidates << spec_file
          # lib/foo/bar_spec.rb -> lib/bar_spec.rb
          candidates << candidates.last.sub($&, '')
          # lib/bar_spec.rb -> bar_spec.rb
          candidates << candidates.last.sub(%r:\w+/:, '') if candidates.last.index('/')
        when 'config/routes.rb'
          candidates << 'controllers' << 'helpers' << 'views' << 'routing'
        when 'config/database.yml', 'db/schema.rb', 'spec/factories.rb'
          candidates << 'models'
        when 'config/boot.rb', 'config/environment.rb', %r:^config/environments/:, %r:^config/initializers/:, %r:^vendor/:, 'spec/spec_helper.rb'
          Spork.reload if runner.options[:spork]
          Celerity.restart if runner.options[:celerity]
          candidates << 'spec'
        when %r:^config/:
          # nothing
        when %r:^(spec/(spec_helper|shared/.*)|config/(boot|environment(s/test)?))\.rb$:, 'spec/spec.opts', 'spec/fakeweb.rb'
          candidates << 'spec'
        else
          candidates << spec_file
        end
      end
      
      candidates.map do |candidate|
        if candidate == 'cucumber'
          candidate
        elsif candidate.index('spec') == 0
          File.join(root, candidate)
        else
          File.join(root, 'spec', candidate)
        end
      end
    end
    
    def append_spec_file_extension(file)
      if File.extname(file) == ".rb"
        file.sub(/.rb$/, "_spec.rb")
      else
        file + "_spec.rb"
      end
    end
    
    def spec_file?(file)
      file =~ /^spec\/.+_spec.rb$/
    end
    def cucumber_file?(file)
      file =~ /^features\/.+$/
    end
  end
end