$:.unshift File.dirname(__FILE__) + '/../app/controller'
$:.unshift File.dirname(__FILE__) + '/../app/lib'
$:.unshift File.dirname(__FILE__) + '/../app/ns_ext'
$:.unshift File.dirname(__FILE__) + '/../app/object'
$:.unshift File.dirname(__FILE__) + '/../app/view'
$:.unshift File.dirname(__FILE__) + '/../app/helper'

$fpath_simple   = File.join(File.dirname(__FILE__), 'fixtures/maps/simple')
$fpath_doubles  = File.join(File.dirname(__FILE__), 'fixtures/maps/doubles')
$fpath_rails    = File.join(File.dirname(__FILE__), 'fixtures/maps/rails')

require 'osx/cocoa'
require 'string'
require 'ns_object'
require 'log'

# Disable Logger output in test environment
class Logger
  def format_message(severity, timestamp, progname, msg)
    f = "#{timestamp.to_s} :: #{severity} :: #{msg}\n"
    return f 
  end
end
