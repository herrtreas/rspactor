require 'osx/cocoa'

class Notification < OSX::NSObject
  def self.init
    @@_self = Notification.new
  end
  
  def self.subscribe(handled_by, subscription)
    @@_self.subscribe(handled_by, subscription)
  end

  def self.send(name, *args)
    @@_self.send(name, *args)
  end
  
  def subscribe(handled_by, subscription)    
    OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(
      handled_by, 
      subscription.values.first.to_s, 
      subscription.keys.first.to_sym, 
      nil 
    )          
  end  
  
  def send(name, *args)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object_userInfo(name.to_s, self, args)    
  end    
  
end