class BuildsController < ApplicationController
  def show
    @project = Project.find_by_name(params[:project_name])
    @build = @project.builds.find_by_number(params[:build_number])
  end
end
