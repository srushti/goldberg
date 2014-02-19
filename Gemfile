source 'https://rubygems.org'

gem 'rails', '4.0.3'

gem 'sqlite3', '~> 1.3.3', platforms: [:ruby, :mswin]
gem 'haml', '~> 4.0.0'
gem 'sass', '~> 3.2.0'
gem 'commander', '~> 4.1.2'
gem 'childprocess', '0.3.6'
gem 'json', '~> 1.8.0', platforms: [:ruby_18, :jruby]
gem 'kaminari', '~> 0.14.1'

gem 'foreman', "~> 0.63.0"
gem 'bigdecimal', '~> 1.2.1', platforms: [:ruby_18, :ruby_19]

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end

platform :jruby do
  gem 'jdbc-sqlite3', '~> 3.7.2'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.3.1'
  gem 'jruby-openssl', '~> 0.9.0'
end

group :development, :test do
  gem 'require_relative', '~> 1.0.3', platforms: [:ruby_18]
  gem 'ffi-ncurses', '~> 0.4.0', platforms: :jruby
  gem 'rspec-rails', '~> 2.14.0'
end

gem 'puma', '~> 2.6.0', platforms: :rbx

group :test do
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'rspec-http', '~> 0.10.0'
  gem 'simplecov'
end
