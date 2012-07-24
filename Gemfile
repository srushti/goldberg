source 'http://rubygems.org'

gem 'rails', '3.2.6'

gem 'sqlite3', '~> 1.3.3', :platforms => :ruby
gem 'haml', '~> 3.1.4'
gem 'sass', '~> 3.1.10'
gem 'commander', '~> 4.1.2'
gem 'childprocess', '~> 0.3.1'
gem 'json', '~> 1.7.3', :platforms => [:ruby_18, :jruby]

gem 'foreman', "~> 0.53.0"

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.7.2'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.2.2'
  gem 'jruby-openssl', '~> 0.7.7'
end

group :development, :test do
  gem 'require_relative', '~> 1.0.3', :platforms => [:ruby_18]
  gem 'ffi-ncurses', '~> 0.4.0', :platforms => :jruby
  gem 'rspec-rails', '~> 2.0'
  gem 'spork', '~> 0.9.0'
end

group :development do
  gem 'puma', '~> 1.5.0'
end

group :test do
  gem 'factory_girl_rails', '~> 3.5.0'
  gem 'rspec-http', '~> 0.10.0'
  gem 'simplecov'
end
