module ApplicationHelper
  def project_status(passed)
    passed.gsub(/ /, '_')
  end
end
