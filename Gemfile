source 'https://rubygems.org'

gem 'rails', '3.2.12'

gem 'sqlite3', '~> 1.3.3', :platforms => [:ruby, :mswin]
gem 'haml', '~> 4.0.0'
gem 'sass', '~> 3.2.0'
gem 'commander', '~> 4.1.2'
gem 'childprocess', '0.3.6'
gem 'json', '~> 1.7.3', :platforms => [:ruby_18, :jruby]
gem 'kaminari', '~> 0.14.1'

gem 'foreman', "~> 0.61.0"
gem 'bigdecimal', '~> 1.1.0', :platforms => [:ruby_18, :ruby_19]

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.7.2'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.2.2'
  gem 'jruby-openssl', '~> 0.8.2'
end

group :development, :test do
  gem 'require_relative', '~> 1.0.3', :platforms => [:ruby_18]
  gem 'ffi-ncurses', '~> 0.4.0', :platforms => :jruby
  gem 'rspec-rails', '~> 2.13.0'
end

gem 'puma', '~> 1.6.1', :platforms => :rbx

group :test do
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'rspec-http', '~> 0.10.0'
  gem 'simplecov'
end
