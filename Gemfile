source 'http://rubygems.org'

gem 'rails', '3.2.8'

gem 'sqlite3', '~> 1.3.3', :platforms => [:ruby, :mswin]
gem 'haml', '~> 3.1.4'
gem 'sass', '~> 3.2.0'
gem 'commander', '~> 4.1.2'
gem 'childprocess', '~> 0.3.1'
gem 'json', '~> 1.7.3', :platforms => [:ruby_18, :jruby]
gem 'kaminari', '~> 0.14.1'

gem 'foreman', "~> 0.59.0"
gem 'bigdecimal', '~> 1.1.0', :platforms => [:ruby]

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

gem 'puma', '~> 1.6.1', :platforms => :rbx

group :test do
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'rspec-http', '~> 0.10.0'
  gem 'simplecov'
end
