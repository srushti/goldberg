$:.unshift File.dirname(__FILE__) + "/lib/"
require 'goldberg_api'
run GoldbergApi::Application
