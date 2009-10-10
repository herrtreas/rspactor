module RSpactor
  module Growl
    extend self
    
    def notify(title, msg, icon, pri = 0)
      system("growlnotify -w -n rspactor --image #{image_path(icon)} -p #{pri} -m #{msg.inspect} #{title} &") 
    end
    
    # failed | pending | success
    def image_path(icon)
      File.expand_path File.dirname(__FILE__) + "/../../images/#{icon}.png"
    end
  end
end