module ApplicationHelper
  def project_status(project)
    status(project.latest_build_status)
  end

  def build_status(build)
    status(build.status)
  end

  def status(s)
    s.gsub(/ /, '_')
  end
end
