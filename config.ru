$:.unshift File.dirname(__FILE__) + "/lib/"
require 'goldberg_api'

if ENV['RACK_ENV'] == 'production'
  log = File.new("logs/sinatra.log", "a")
  STDOUT.reopen(log)
  STDERR.reopen(log)
  puts "starting in #{ENV['RACK_ENV']} mode, redirecting output to sinatra.log"
end

Thread.start{ Goldberg::Init.new.start_poller }

run GoldbergApi::Application
