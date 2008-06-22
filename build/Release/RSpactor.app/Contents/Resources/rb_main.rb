require 'osx/cocoa'
include OSX

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|    
    require( File.basename(path) ) unless path.include?('rspactor_bin.rb')
  end
end


if $0 == __FILE__ then
  rb_main_init
  NSApplication.sharedApplication 
  NSApp.setDelegate(AppController.alloc.init) 
  OSX.NSApplicationMain(0, nil)
end
