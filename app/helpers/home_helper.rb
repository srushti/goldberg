module HomeHelper
  def project_status_image(status)
    if ['building', 'not_available', 'cancelled'].include?(status)
      image_tag "#{status}.gif", :alt => status, :title => status
    else
      image_tag "#{status}.png", :alt => status, :title => status
    end
  end
end

