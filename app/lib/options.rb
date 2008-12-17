module Options
  class << self
    def summarize_growl_output?
      $app.default_from_key(:generals_summarize_growl_output) == '1'
    end
    
    def use_spec_server?
      $app.default_from_key(:generals_auto_activate_spec_server, '0') == '1'
    end
  end
end