source 'http://rubygems.org'

gem 'rails', '3.0.10'

gem 'sqlite3', '~> 1.3.3', :platforms => :ruby
gem 'haml', '~> 3.1.2'
gem 'sass', '~> 3.1.2'
gem 'commander', '~> 4.0.4'
gem 'childprocess', '~> 0.1.9'
gem 'json', :platforms => [:ruby_18, :jruby]

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.6.0'
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :development, :test do
  gem 'ruby-debug', :platforms => [:ruby_18, :jruby]
  gem 'require_relative', :platforms => [:ruby_18]
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'ffi-ncurses', :platforms => :jruby
  gem 'rspec-rails', '~> 2.0'
  gem 'spork', '~> 0.9.0.rc'
end

group :development do
  if RUBY_PLATFORM == 'java'
    # See https://github.com/carlhuda/bundler/issues/1100
    gem 'mongrel', '~> 1.0'
  else
    gem 'mongrel', '~> 1.2.0.pre2'
  end
end

group :test do
  gem 'factory_girl_rails', '~> 1.0.1'
  gem 'rspec-http', '~> 0.0.2'
  gem 'simplecov'
end
