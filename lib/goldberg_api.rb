require 'goldberg'
require "haml"
require File.join(File.dirname(__FILE__), 'goldberg', 'project')

Bundler.require(:web)
require "sinatra/outputbuffer"

set :views, File.join(File.dirname(__FILE__), 'views')
set :public, File.join(File.dirname(__FILE__), '..', 'public')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

module GoldbergApi
  class Application < Sinatra::Application
    helpers Sinatra::OutputBuffer::Helpers
    
    get '/' do
      haml :index, :locals => { :projects => Goldberg::Project.all }
    end

    get "/projects/:project_name" do
      if !Goldberg::Project.all.map(&:name).include?(params[:project_name])
        status 404
      else
        haml :project, :locals => { :project => Goldberg::Project.new(params[:project_name]) }
      end
    end

    post "/projects/:project_name/force" do
      if !Goldberg::Project.all.map(&:name).include?(params[:project_name])
        status 404
      else
        project = Goldberg::Project.new(params[:project_name])
        project.force_build
        redirect back
      end
    end
  end
end
