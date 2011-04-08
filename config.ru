# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
Thread.start{Init.new.start_poller} if Rails.env == 'development'
run Goldberg::Application
