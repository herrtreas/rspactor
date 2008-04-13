#!/usr/bin/env ruby
require 'drb'
require 'timeout'

rspactor_bin_path = ARGV[0] == "--dev" ? "/Users/andreas/ruby/rspactor/build/Debug" : "/Applications/"
rspactor_bin_path += "/RSpactor.app"

system("open #{rspactor_bin_path}")
drb = DRbObject.new(nil, "druby://127.0.0.1:281282")

Timeout::Timeout(5) do
  while drb.remote_call_in(:ping) != true
    sleep 0.1
  end
end

drb.remote_call_in(:change_location, Dir.pwd)
