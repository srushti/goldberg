$:.unshift File.dirname(__FILE__) + "/lib/"
require 'goldberg_api'

Thread.start{ Goldberg::Init.new.start_poller }

run GoldbergApi::Application
