require 'goldberg'
require "haml"
require File.join(File.dirname(__FILE__), 'goldberg', 'project')

Bundler.require(:web)

set :views, File.join(File.dirname(__FILE__), 'views')

module GoldbergApi
  class Application < Sinatra::Application
    get '/' do
      haml :index
    end
  end
end
