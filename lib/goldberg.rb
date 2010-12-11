require 'rubygems'
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running 'bundle install'."
  exit!
end
Bundler.require(:default)

module Goldberg
end

['/goldberg/**/*.rb'].each do |directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"] do { |file|
    require file
  end
end


