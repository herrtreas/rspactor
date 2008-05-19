#!/usr/bin/env ruby
require 'drb'
require 'timeout'

rspactor_bin_path = ARGV[0] == "--dev" ? "/Users/andreas/ruby/rspactor/build/Debug" : "/Applications/"
rspactor_bin_path += "/RSpactor.app"


# Load application
system("RSPACTOR_RUN_PATH=#{Dir.pwd}; open #{rspactor_bin_path}")