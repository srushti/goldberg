class ProjectsController < ApplicationController
  def show
    @project = Project.find_by_name(params[:id])
    if @project.nil?
      render :text => 'Unknown project', :status => :not_found
    end
  end

  def force
    project = Project.find_by_id(params[:project_id])
    if project
      project.force_build
      redirect_to :back
    else
      render :text => 'Unknown project', :status => :not_found
    end
  end
end
