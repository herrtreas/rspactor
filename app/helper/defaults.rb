require 'osx/cocoa'

class Defaults
  def self.get(key, rescue_value = '')
    OSX::NSUserDefaults.standardUserDefaults.stringForKey(key) || rescue_value
  end
  
  def self.set(key, value)
    OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(value, key.to_s)
  end  
  
  def self.method_missing(symbol, *args)
    if symbol.to_s.reverse[0..0] == '?'
      self.get(symbol) == '1'
    else
      super
    end
  end
end