class BuildsController < ApplicationController
  def show
    @project = Project.find_by_name(params[:project_name])
    if @project
      @build = @project.builds.find_by_number(params[:build_number])
      render :text => 'Unknown build', :status => :not_found if @build.nil?
    else
      render :text => 'Unknown project', :status => :not_found
    end
  end
end
