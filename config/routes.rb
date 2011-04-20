Goldberg::Application.routes.draw do
  root :to => "home#index"
  ['XmlStatusReport.aspx', 'cctray.xml', 'cc.xml'].each do |route|
    get route, :to => 'home#ccfeed', :defaults => {:format => 'xml'}
  end

  get '/projects/:project_name' => 'projects#show', as: :project
  post '/projects/:project_name/force' => 'projects#force', as: :project_force

  get '/projects/:project_name/builds/:build_number' => 'builds#show', as: :project_build
end
