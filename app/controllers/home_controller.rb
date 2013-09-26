class HomeController < ApplicationController
  before_filter :load_projects, only: [:index, :projects_partial]

  def load_projects
    all_projects = params[:group_name] ? Project.all.select{|p| p.group == params[:group_name]} : Project.all
    @grouped_projects = all_projects.sort_by {|x| x.latest_build.updated_at || DateTime.now }.reverse.group_by(&:group)
  end

  def projects_partial
    render partial: 'group_projects', locals: { grouped_projects: @grouped_projects }
  end

  def ccfeed
    respond_to do |format|
      format.xml do
        @projects = Project.all
        render :ccfeed, format: :xml, layout: false
      end
    end
  end
end
