require 'osx/cocoa'

def require_rb_files(directories)
  directories.each do |d|
    Dir.glob(File.join(File.dirname(__FILE__), "app/#{d}", "**", "*.rb")).each { |f| require f }
  end
end

def require_rspactor_libs
  require_rb_files %w(lib object view controller)
end

if $0 == __FILE__ then  
  begin
    require_rspactor_libs
    $LOG.debug 'Loading application'
    $all_specs, $failed_specs, $pending_specs = [], [], []

    $coreInterop = RSpactor::Core::Interop.new
    $LOG.debug 'Ready for startup'
    OSX.NSApplicationMain(0, nil)
    
  rescue => e
    puts "#{e.message}"
    $LOG.error "#{e.message}: #{e.backtrace.first}"
  ensure
    $LOG.debug 'Exit. Bye.'
  end
end
