class HomeController < ApplicationController
  before_filter :load_projects, :only => [:index, :projects_partial]

  def load_projects
    @projects = Project.all.sort_by {|x| x.latest_build.updated_at || DateTime.now }.reverse
  end

  def projects_partial
    render :partial => 'projects'
  end

  def ccfeed
    respond_to do |format|
      format.xml do
        @projects = Project.all
        render :ccfeed, :format => :xml, :layout => false
      end
    end
  end
end
