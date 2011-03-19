class HomeController < ApplicationController
  def index
    @projects = Project.all
    @keep_refreshing = true
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
