require 'spec/runner/formatter/base_formatter'
require File.dirname(__FILE__) + '/rspactor/growl'

class RSpecGrowler < Spec::Runner::Formatter::BaseFormatter
  include RSpactor::Growl
  
  def dump_summary(duration, total, failures, pending)
    icon = if failures > 0
      'failed'
    elsif pending > 0
      'pending'
    else
      'success'
    end
    
    # image_path = File.dirname(__FILE__) + "/../images/#{icon}.png"
    message = "#{total} examples, #{failures} failures"
    if pending > 0
      message << " (#{pending} pending)"
    end
    
    notify "Spec Results", message, icon
  end
end