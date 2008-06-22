require File.dirname(__FILE__) + '/spec_object'
require File.dirname(__FILE__) + '/log'

class RSpactorFormatter
  attr_accessor :example_group, :options, :where
  
  def initialize(options, where)
    @options = options
    @where = where
    @remote_service = DRbObject.new(nil, "druby://127.0.0.1:28127")
    $LOG.debug 'Remote: Initialized'
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @remote_service.incoming(:spec_run_dump_summary, duration, example_count, failure_count, pending_count)
  end

  def start(example_count)
    $LOG.debug "Remote: Started spec run for #{example_count} specs"
    @remote_service.incoming(:spec_run_start, example_count)
  end

  def add_example_group(example_group)
    @example_group = example_group
  end

  def example_passed(example)
    spec = SpecObject.new(
      :name               => example.description,
      :example_group_name => @example_group.description,
      :state              => :passed,
      :backtrace          => example.implementation_backtrace
    )
    @remote_service.incoming(:spec_run_example_passed, spec)
  end
  
  def example_pending(example, message)
    spec = SpecObject.new(
      :name               => example.description,
      :example_group_name => @example_group.description,
      :state              => :pending,
      :message            => message,
      :backtrace          => example.implementation_backtrace
    )        
    @remote_service.incoming(:spec_run_example_pending, spec)
  end

  def example_failed(example, counter, failure)
    spec = SpecObject.new(        
      :name               => example.description,
      :example_group_name => @example_group.description,
      :state              => :failed,
      :message            => failure.exception.message,
      :error_header       => failure.header,
      :error_type         => failure.expectation_not_met? ? :expectation : :implementation,
      :backtrace          => extract_backspace(failure.exception.backtrace)
    )
    @remote_service.incoming(:spec_run_example_failed, spec)
  end  

  def close
    @remote_service.incoming(:spec_run_close)
    $LOG.debug "Remote: Closed"        
  end
  
  # Currently unused callbacks
  def example_started(example); end    
  def start_dump; end
  def dump_failure(counter, failure); end
  def dump_pending; end

  
  private
  
    def extract_backspace(backtrace)
      return [] if backtrace.nil?
      backtrace.map { |line| line.sub(/\A([^:]+:\d+)$/, '\\1:') }
    end
  
end