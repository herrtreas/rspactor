require 'logger'
require 'fileutils'

class Logger
  def format_message(severity, timestamp, progname, msg)
    f = "#{timestamp.to_s} :: #{severity} :: #{msg}\n"
    puts f
    return f 
  end
end

def init_logger
  clean_logs
  $LOG = Logger.new("#{ENV['HOME']}/Library/Logs/rspactor.log", 'daily')
  $LOG.level = Logger::DEBUG
end

def clean_logs
  FileUtils.rm_f(Dir.glob("#{ENV['HOME']}/Library/Logs/rspactor.log.*"))
end

init_logger