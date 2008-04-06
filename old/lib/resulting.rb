class RSpactorFormatter
  attr_accessor :example_group, :options, :where
  def initialize(options, where)
    @options = options
    @where = where
  end
  
  def dump_summary(duration, example_count, failure_count, pending_count)
    img = (failure_count == 0) ? "rails_ok.png" : "rails_fail.png"
    growl "Test Results", "#{example_count} examples, #{failure_count} failures", File.dirname(__FILE__) + "/../asset/#{img}", 0
  end

  def start(example_count)
  end

  def add_example_group(example_group)
  end

  def example_started(example)
  end

  def example_passed(example)
  end

  def example_failed(example, counter, failure)
  end
  
  def example_pending(example_group_description, example, message)
  end

  def start_dump
  end

  def dump_failure(counter, failure)
  end

  def dump_pending
  end

  def close
  end
  
  def growl(title, msg, img, pri = 0)
    system("growlnotify -w -n rspactor --image #{img} -p #{pri} -m #{msg.inspect} #{title} &") 
  end
end

