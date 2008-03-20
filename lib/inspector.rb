# The inspector make some assumptions about how your project is structured and where your spec files are located.
# That said: The 'spec' directory, containing all your test files, must rest in the root directory of your project.
# Futhermore it tries to locate controller, model, helper and view specs for a rails app (or projects with an identical structure)
# in root/spec/controllers, root/spec/models, root/spec/helpers and root/spec/views.

class Inspector

  attr_accessor :base_spec_root
  
  def self.file_is_invalid?(file)
    return true unless File.basename(file) =~ /.rb\z|.rhtml\z|.erb\z|.haml\z/
    false
  end
  
  def find_spec_file(file)
    begin
      return file if file_is_a_spec?(file)
      spec_root = find_base_spec_root_by_file(file)
      if spec_root
        guessed_spec_location = guess_spec_location(file, spec_root)
        if File.exist?(guessed_spec_location)
          @base_spec_root = spec_root
          return guessed_spec_location
        end
      end
      nil      
    rescue => e
      puts "Error while parsing a file: '#{file}'"
      puts e
    end
  end
  
  def inner_spec_directory(path)
    spec_base_root = find_base_spec_root_by_file(Dir.pwd + "/.")
    inner_location = extract_inner_project_location(Dir.pwd, spec_base_root)
    File.join(spec_base_root, inner_location)
  end
  
  def find_base_spec_root_by_file(file)
    if @base_spec_root
      return @base_spec_root
    else
      dir_parts = File.dirname(file).split("/")
      dir_parts.size.times do |i|
        search_dir = dir_parts[0..dir_parts.length - i - 1].join("/") + "/"
        if Dir.entries(search_dir).include?('spec')
          @assumed_spec_root = search_dir + "spec" 
          break
        end
      end
      return @assumed_spec_root
    end
  end
  
  def guess_spec_location(file, spec_root)
    inner_location = extract_inner_project_location(file, spec_root)
    append_spec_file_extension(File.join(spec_root, inner_location))
  end

  def project_root(spec_root)
    spec_root.split("/")[0...-1].join("/")
  end
  
  def extract_inner_project_location(file, spec_root)
    location = file.sub(project_root(spec_root), "")
    adapt_rails_specific_app_structure(location)
  end
  
  def adapt_rails_specific_app_structure(location)
    # Removing 'app' if its a rails controller, model, helper or view
    fu = location.split("/")
    if fu[1] == "app" && (fu[2] == 'controllers' || fu[2] == 'helpers' || fu[2] == 'models' || fu[2] == 'views')
      return "/" + fu[2..fu.length].join("/")
    end
    location
  end
  
  def append_spec_file_extension(spec_file)
    if File.extname(spec_file) == ".rb"
      return File.join(File.dirname(spec_file), File.basename(spec_file, ".rb")) + "_spec.rb"
    else
      return spec_file + "_spec.rb"
    end
  end
  
  def file_is_a_spec?(file)
    if file.split("/").include?('spec') && File.basename(file).match(/_spec.rb\z/)
      return true
    end
    false
  end
end