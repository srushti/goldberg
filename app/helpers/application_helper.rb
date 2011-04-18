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

  def format_timestamp(timestamp)
    content_tag(:span, "#{time_ago_in_words(timestamp)} ago", :title => timestamp.strftime("%a, %Y/%m/%d %I:%M%p %Z")).tap{|html| puts html}
  end
end
