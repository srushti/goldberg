class BuildsController < ApplicationController
  before_filter :load_project_and_build, :except => [:index]

  def load_project_and_build
    @project = Project.find_by_name(params[:project_name])
    if @project
      @builds = @project.builds.page(params[:page])
      @build = @project.builds.find_by_number(params[:build_number])
      render :text => 'Unknown build', :status => :not_found if @build.nil?
    else
      render :text => 'Unknown project', :status => :not_found
    end
  end

  def artefact_path(path = '')
    artefact_path = File.join(Paths.projects, @project.name, 'builds', @build.number.to_s, 'artefacts', path)
  end

  def artefact
    @path = artefact_path(params[:path])
    if Environment.expand_path(@path).match(/^#{Regexp.escape(artefact_path)}/)
      if Environment.directory?(@path)
        @entries = (Dir.entries(@path) - ['.', '..']).map{|entry| File.join(params[:path], entry)}
        render 'artefact_directory'
      elsif Environment.exist?(@path)
        extension = File.extname(@path)
        mime_type = Mime::Type.lookup_by_extension(extension[1, extension.size])
        send_file @path, :disposition => 'inline', :content_type => mime_type || 'application/octet-stream'
      else
        render :text => 'Unknown file', :status => :not_found
      end
    else
      render :text => 'Naughty, naughty', :status => 403
    end
  end

  def show
    respond_to do |format|
      format.html { render :layout => (params[:_pjax] ? false : 'builds') }
      format.json { render :json => @build }
    end
  end

  def index
    respond_to do |format|
      format.html { redirect_to project_path(params[:project_name]) }
      format.json { render :json => Project.find_by_name(params[:project_name]).builds.to_json }
    end
  end

  def cancel
    @build.cancel
    redirect_to :back
  end
end
