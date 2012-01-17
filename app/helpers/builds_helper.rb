module BuildsHelper
  def revision_number_text(build)
    if build.project.github_url
      link_to "#{build.revision.slice(0,6)}", "#{build.project.github_url}/commit/#{build.revision}"
    else
      build.revision.slice(0, 6)
    end
  end
end
