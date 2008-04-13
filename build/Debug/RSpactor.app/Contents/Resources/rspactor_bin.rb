#!/usr/bin/env ruby
require 'drb'

rspactor_bin_path = ARGV[0] == "--dev" ? "/Users/andreas/ruby/rspactor/build/Debug" : "/Applications/"
rspactor_bin_path += "/RSpactor.app"

system("open #{rspactor_bin_path}")

drb = DRbObject.new(nil, "druby://127.0.0.1:281282")
drb.remote_call_in(:change_location, Dir.pwd)
