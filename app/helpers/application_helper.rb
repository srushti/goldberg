module ApplicationHelper
  def project_status(status)
    status.gsub(/ /, '_')
  end                  
  
  def format_timestamp(timestamp)
#    haml_tag(:div, :class => 'timestamp') do
       haml_concat timestamp.strftime("%a, %Y/%m/%d %I:%M%p %Z") 
       haml_concat "( "
       haml_concat time_ago_in_words(timestamp)       
       haml_concat " ago )"         
#     end
  end  
end
