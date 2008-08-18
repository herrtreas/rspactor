require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  ib_outlet :panel, :specBinPath, :rubyBinPath, :tmBinPath
  
  def initialize
    unless $app.default_from_key(:spec_bin_path, nil)
      spec_bin_path = `/usr/bin/which spec`
      $app.default_for_key(:spec_bin_path, spec_bin_path) unless spec_bin_path.empty?
    end
    unless $app.default_from_key(:ruby_bin_path, nil)
      ruby_bin_path = `/usr/bin/which ruby`
      $app.default_for_key(:ruby_bin_path, ruby_bin_path) unless ruby_bin_path.empty?
    end
    unless $app.default_from_key(:tm_bin_path, nil)
      tm_bin_path = `/usr/bin/which mate`
      $app.default_for_key(:tm_bin_path, tm_bin_path) unless tm_bin_path.empty?
    end
    receive :file_doesnot_exist,  :showPathErrorAlert
  end
  
  def awakeFromNib
    set_default_spec_bin_path
    set_default_ruby_bin_path
    set_default_tm_bin_path
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

  def set_default_tm_bin_path
    @tmBinPath.stringValue = $app.default_from_key(:tm_bin_path, '/usr/bin/mate')
  end
  
  def controlTextDidEndEditing(notification)
    check_path_and_set_default(:spec_bin_path, @specBinPath.stringValue)  if notification.object.stringValue == @specBinPath.stringValue
    check_path_and_set_default(:ruby_bin_path, @rubyBinPath.stringValue)  if notification.object.stringValue == @rubyBinPath.stringValue
    check_path_and_set_default(:tm_bin_path, @tmBinPath.stringValue)      if notification.object.stringValue == @tmBinPath.stringValue
  end
  
  def check_path_and_set_default(key, path)
    $app.default_for_key(key, path) if $app.file_exist?(path)
  end
  
  def showPathErrorAlert(notification)
    path = notification.userInfo.first
    return unless path == @specBinPath.stringValue || path == @rubyBinPath.stringValue || path == @tmBinPath.stringValue
    
    alert = NSAlert.alloc.init
    alert.alertStyle = OSX::NSCriticalAlertStyle
    alert.messageText = "The path '#{path}' doesn't exist.."
    alert.runModal
  end
end