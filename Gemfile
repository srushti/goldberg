source 'http://rubygems.org'

gem 'rails', '3.2.6'

gem 'sqlite3', '~> 1.3.3', :platforms => :ruby
gem 'haml', '~> 3.1.4'
gem 'sass', '~> 3.1.10'
gem 'commander', '~> 4.1.2'
gem 'childprocess', '~> 0.3.1'
gem 'json', :platforms => [:ruby_18, :jruby]

gem 'foreman', "~> 0.22.0"

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.7.2'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl', '~> 0.7.6.1'
end

group :development, :test do
  gem 'require_relative', :platforms => [:ruby_18]
  gem 'ffi-ncurses', :platforms => :jruby
  gem 'rspec-rails', '~> 2.0'
  gem 'spork', '~> 0.9.0'
end

group :development do
  gem 'puma'
end

group :test do
  gem 'factory_girl_rails', '~> 3.0.0'
  gem 'rspec-http', '~> 0.9.0'
  gem 'simplecov'
end
