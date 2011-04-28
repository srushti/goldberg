class BuildsController < ApplicationController
  before_filter :load_project_and_build

  def load_project_and_build
    @project = Project.find_by_name(params[:project_name])
    if @project
      @build = @project.builds.find_by_number(params[:build_number])
      render :text => 'Unknown build', :status => :not_found if @build.nil?
    else
      render :text => 'Unknown project', :status => :not_found
    end
  end

  def artefact
    artefact_path = File.join(Paths.projects, @project.name, 'builds', @build.number.to_s, 'artefacts', "#{params[:path]}.txt")
    if File.exist?(artefact_path)
      render :file => artefact_path
    else
      render :text => 'Unknown file', :status => :not_found
    end
  end
end
