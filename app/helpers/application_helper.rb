module ApplicationHelper
  def project_status(status)
    status.gsub(/ /, '_')
  end                  
  
  def format_timestamp(timestamp)
    haml_concat timestamp.strftime("%a, %Y/%m/%d %I:%M%p %Z") 
    haml_concat "( #{time_ago_in_words(timestamp)} ago )"
  end  
end
