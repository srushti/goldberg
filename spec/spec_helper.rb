require 'rubygems'
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'environment.rb'
end

ENV["RAILS_ENV"] ||= 'test'
ENV["GOLDBERG_PATH"] ||= File.join(File.expand_path('../../', __FILE__), 'tmp', 'goldberg')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/http'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.include(Goldberg::ExpectationHelpers)
  config.before(:each) do
    FileUtils.stub(:mkdir_p)
  end
end
