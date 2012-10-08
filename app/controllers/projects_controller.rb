class ProjectsController < ApplicationController
  def show
    @project = Project.find_by_name(params[:project_name])
    if @project.nil?
      render :text => 'Unknown project', :status => :not_found
    else
      respond_to do |format|
        format.html do
          @builds = @project.builds.page(params[:page])
          @build = @builds.first
          render 'builds/show', :layout => 'builds'
        end
        format.json { render :json => @project.to_json(:except => [:created_at, :modified_at], :methods => [:activity, :last_complete_build_status, :last_complete_build_number])}
        format.png do
          filename = status_to_filename(@project.last_complete_build_status)
          send_file File.join(Rails.public_path, "images/badge/#{filename}.png"), :disposition => 'inline', :content_type => Mime::Type.lookup_by_extension('png')
        end
      end
    end
  end

  def status_to_filename(status)
    return 'failed' if status == 'timeout'
    return status if ['passed', 'failed'].include?(status)
    return 'unknown'
  end

  def force
    project = Project.find_by_name(params[:project_name])
    if project
      project.force_build
      redirect_to :back
    else
      render :text => 'Unknown project', :status => :not_found
    end
  end

  def index
    respond_to do |format|
      format.json { render :json => Project.all.to_json(:except => [:created_at, :modified_at], :methods => [:activity, :last_complete_build_status, :last_complete_build_number]) }
      format.html { redirect_to root_path }
    end
  end
end
