module OSX
  class NSObject
    def receive(notification, run_method_sym)
      OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, run_method_sym.to_sym, notification.to_s, nil)          
    end
  end
end