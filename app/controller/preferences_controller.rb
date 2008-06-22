require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  ib_outlet :panel, :specBinPath, :rubyBinPath
  
  def initialize
    unless $app.default_from_key(:spec_bin_path, nil)
      spec_bin_path = `/usr/bin/which spec`
      $app.default_for_key(:spec_bin_path, spec_bin_path) unless spec_bin_path.empty?
    end
    unless $app.default_from_key(:ruby_bin_path, nil)
      ruby_bin_path = `/usr/bin/which ruby`
      $app.default_for_key(:ruby_bin_path, ruby_bin_path) unless ruby_bin_path.empty?
    end
  end
  
  def awakeFromNib
    set_default_spec_bin_path
    set_default_ruby_bin_path
  end
  
  def showWindow(sender)
    @panel.makeKeyAndOrderFront(self)
  end
  
  def set_default_spec_bin_path
    @specBinPath.stringValue = $app.default_from_key(:spec_bin_path, '/usr/bin/spec')
  end
  
  def set_default_ruby_bin_path
    @rubyBinPath.stringValue = $app.default_from_key(:ruby_bin_path, '/usr/bin/ruby')
  end
  
  def controlTextDidChange(notification)
    $app.default_for_key(:spec_bin_path, @specBinPath.stringValue)
    $app.default_for_key(:ruby_bin_path, @rubyBinPath.stringValue)
  end
  
end