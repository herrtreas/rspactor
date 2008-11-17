#!/usr/bin/env ruby
require 'timeout'
require 'drb'

# Load application
if ARGV[0] == '--dev'
  system("open /Work/rubyphunk/rspactor_app/build/Release/RSpactor.app")
else
  system('open -b com.dynamicdudes.RSpactor')
end

# Ping and Pong
Timeout::timeout(10) do
  @service = DRbObject.new(nil, "druby://127.0.0.1:28127")    
  while true
    begin
      if @service.ping
        @service.incoming(:relocate_and_run, Dir.pwd)
        exit
      end
    rescue; end
    sleep 1
  end
end
