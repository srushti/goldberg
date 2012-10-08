module BuildsHelper
  def revision_number_text(build)
    if build.project.github_url
      link_to "#{build.revision.slice(0,6)}", "#{build.project.github_url}/commit/#{build.revision}", :class => 'external-link'
    else
      build.revision.slice(0, 6)
    end
  end

  def pagination_links(project)
    current_page = (params[:page] || 1).to_i
    links = []
    links << link_to("Previous", project_path(project.name, page: current_page - 1)) if current_page > 1
    links << link_to("Next", project_path(project.name, page: current_page + 1)) if current_page * Build.per_page < project.builds.size
    links.join(' ').html_safe
  end
end
