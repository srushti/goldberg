require 'goldberg'

Bundler.require(:web)

module GoldbergApi
  class Application < Sinatra::Application
    get '/' do
      'Butterfly'
    end
  end
end
