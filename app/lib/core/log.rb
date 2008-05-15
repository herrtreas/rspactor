require 'logger'

class Logger
  def format_message(severity, timestamp, progname, msg)
    f = "#{timestamp.to_s} :: #{severity} :: #{msg}\n"
    puts f
    return f 
  end
end

def init_logger
  $LOG = Logger.new("#{ENV['HOME']}/Library/Logs/rspactor.log", 'daily')
  $LOG.level = Logger::DEBUG
end

init_logger