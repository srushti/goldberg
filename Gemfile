source 'http://rubygems.org'

gem 'rails', '3.0.7'

gem 'sqlite3', '~> 1.3.3', :platforms => :ruby
gem 'haml', '~> 3.0.25'
gem 'commander'

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.6.0'
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :development, :test do
  gem 'ruby-debug', :platforms => [:ruby_18, :jruby]
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'ffi-ncurses', :platforms => :jruby
  gem 'rspec-rails', '~> 2.5.0'
  gem 'rspec-http'
  gem 'stirlitz', '~> 0.0.1.1'
  if RUBY_PLATFORM == 'java'
    # See https://github.com/carlhuda/bundler/issues/1100
    gem 'mongrel', '~> 1.0'
  else
    gem 'mongrel', '~> 1.2.0.pre2'
  end
  gem 'spork', '~> 0.9.0.rc'
  gem 'factory_girl_rails', '~> 1.0.1'
end
