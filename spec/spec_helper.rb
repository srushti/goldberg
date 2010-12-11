require 'goldberg'

module RackSpecHelper
  # include Rack::Test::Methods
  # 
  # def app
  #   Sinatra::Application
  # end
end

RSpec.configure do |conf|
  conf.include RackSpecHelper
end

