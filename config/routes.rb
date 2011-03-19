Goldberg::Application.routes.draw do
  root :to => "home#index"
  ['XmlStatusReport.aspx', 'cctray.xml', 'cc.xml'].each do |route|
    get route, :to => 'home#ccfeed', :defaults => {:format => 'xml'}
  end

  resources :projects, :only => :show do
    post :force
    resources :builds, :only => :show
  end
end
