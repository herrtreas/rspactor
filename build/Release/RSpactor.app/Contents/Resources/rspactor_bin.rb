#!/usr/bin/env ruby
rspactor_bin_path = ARGV[0] == "--dev" ? "/Users/andreas/ruby/rspactor/build/Debug" : "/Applications/"
rspactor_bin_path += "/RSpactor.app"

# Load application
system("export RSPACTOR_RUN_PATH=#{Dir.pwd}; open #{rspactor_bin_path}")
sleep 1