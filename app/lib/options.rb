module Options
  class << self
    def summarize_growl_output?
      $app.default_from_key(:generals_summarize_growl_output) == '1'
    end
  end
end