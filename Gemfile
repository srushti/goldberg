source "http://rubygems.org"

gem 'rake'
gem 'rspec', '~> 2.2.0'
gem 'rack-test', '~> 0.5.6', :require => 'rack/test'

group :web do
  gem 'sinatra', '~> 1.1.2'
  gem 'sinatra-static-assets', '~> 0.5.0'
  gem 'haml', '~> 3.0.25'
  gem 'sinatra-outputbuffer', '~> 0.1'
end

group :development do
  if RUBY_VERSION.include?('1.9')
    gem 'ruby-debug19', '~> 0.11.6'
  else
    gem 'ruby-debug'
  end
  gem 'mongrel', '~> 1.2.0.pre2'
end
