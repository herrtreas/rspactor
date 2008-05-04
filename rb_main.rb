require 'osx/cocoa'

def require_rb_files(directories)
  directories.each do |d|
    Dir.glob(File.join(File.dirname(__FILE__), "app/#{d}", "**", "*.rb")).each { |f| require f }
  end
end

if $0 == __FILE__ then
  require_rb_files %w(lib object view controller)
  $all_specs, $failed_specs, $pending_specs = [], [], []

  $coreInterop = RSpactor::Core::Interop.new
  OSX.NSApplicationMain(0, nil)
end
