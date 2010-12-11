require 'goldberg'
require 'goldberg_api'

Bundler.require(:test)

set :environment, :test

module RackSpecHelper
  include Rack::Test::Methods
  
  def app
    GoldbergApi::Application
  end
end

RSpec.configure do |conf|
  conf.include RackSpecHelper
end

