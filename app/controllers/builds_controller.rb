class BuildsController < ApplicationController
  def show
    @project = Project.find_by_name(params[:project_id])
    @build = @project.builds.find(params[:id])
  end
end
