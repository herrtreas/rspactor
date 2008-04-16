#!/usr/bin/env ruby
require 'drb'
require 'timeout'

rspactor_bin_path = ARGV[0] == "--dev" ? "/Users/andreas/ruby/rspactor/build/Debug" : "/Applications/"
rspactor_bin_path += "/RSpactor.app"


# Load application
system("open #{rspactor_bin_path}")

drb = DRbObject.new(nil, "druby://127.0.0.1:28128")

# Wait until RSpactor has registered callbacks
begin
  Timeout::timeout(5) do
    while drb.remote_call_in(:ping) != true
      sleep 0.1
    end
  end
rescue Timeout::Error
  puts "RSpactor service is not responding in time. Please make sure that RSpactor.app is running properly."
end

# Send current location
drb.remote_call_in(:change_location, Dir.pwd)
