module Options
  class << self
    def summarize_growl_output?
      Defaults.get(:generals_summarize_growl_output) == '1'
    end
    
    def use_spec_server?
      Defaults.get(:generals_auto_activate_spec_server, '0') == '1'
    end
  end
end