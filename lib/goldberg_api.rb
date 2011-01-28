require 'goldberg'
require "haml"
require File.join(File.dirname(__FILE__), 'goldberg', 'project')

Bundler.require(:web)

set :views, File.join(File.dirname(__FILE__), 'views')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

module GoldbergApi
  class Application < Sinatra::Application
    get '/' do
      haml :index, :locals => { :projects => Goldberg::Project.all }
    end

    get "/projects/*" do
      haml :project, :locals => { :project => Goldberg::Project.new(params[:splat][0]) }
    end

    post "/projects/*/force" do
      project = Goldberg::Project.new(params[:splat][0])
      project.force_build
      redirect "/projects/#{project.name}"
    end
  end
end
