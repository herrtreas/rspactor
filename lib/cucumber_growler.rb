require 'cucumber'
require 'cucumber/formatter/console'
require File.dirname(__FILE__) + '/rspactor/growl'

module CucumberGrowler
  include RSpactor::Growl
  
  def self.included(base)
    base.class_eval do
      alias original_print_stats print_stats
      include InstanceMethods
      
      def print_stats(features)
        title, icon, messages = '', '', []
        [:failed, :skipped, :undefined, :pending, :passed].reverse.each do |status|
          if step_mother.steps(status).any?
            icon = icon_for(status)
            # title = title_for(status)
            messages << dump_count(step_mother.steps(status).length, "step", status.to_s)
          end
        end
        
        notify "Cucumber Results", messages.reverse.join(", "), icon
        original_print_stats(features)
      end
    end
  end
  
  module InstanceMethods
    def icon_for(status)
      case status
      when :passed
        'success'
      when :pending, :undefined, :skipped
        'pending'
      when :failed
        'failed'
      end
    end
    
    def title_for(status)
      case status
      when :passed
        'Features passed!'
      when :pending
        'Some steps are pending...'
      when :undefined
        'Some undefined steps...'
      when :skipped
        'Some steps skipped...'
      when :failed
        'Failures occurred!'
      end
    end
  end
  
end

module Cucumber::Formatter::Console
  include CucumberGrowler
end