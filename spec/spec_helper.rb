require 'goldberg'
require 'rspec'
require 'rack/test'

set :environment, :test

module RackSpecHelper
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |conf|
  conf.include RackSpecHelper
end

