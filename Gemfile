source 'http://rubygems.org'

gem 'rails', '3.0.5'

gem 'sqlite3', '~> 1.3.3', :platforms => :ruby
gem 'haml', '~> 3.0.25'

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.6.0'
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :development, :test do
  gem "ruby-debug", "~> 0.10.4", :platforms => [:ruby_18, :jruby]
  gem "ruby-debug19", "~> 0.11.6", :platforms => :ruby_19
  gem 'rspec-rails', '~> 2.5.0'
  if RUBY_PLATFORM == 'java'
    # See https://github.com/carlhuda/bundler/issues/1100
    gem 'mongrel', '~> 1.0'
  else
    gem 'mongrel', '~> 1.2.0.pre2'
  end
  gem 'spork', '~> 0.9.0.rc'
end
