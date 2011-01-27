require 'goldberg'
require File.join(File.dirname(__FILE__), 'goldberg', 'project')

Bundler.require(:web)

module GoldbergApi
  class Application < Sinatra::Application
    get '/' do
      Goldberg::Project.all.each.map{|p| "#{p.name} #{p.status}" }.join(' ')
    end
  end
end
