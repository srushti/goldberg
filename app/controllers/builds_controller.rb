class BuildsController < ApplicationController
  def show
    @project = Project.new(params[:project_id])
    @build = @project.builds.detect{|build| build.number == params[:id] }
  end
end
