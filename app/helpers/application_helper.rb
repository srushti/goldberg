module ApplicationHelper
  def project_status(status)
    status.gsub(/ /, '_')
  end
end
