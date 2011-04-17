module HomeHelper
  def project_status_image(status)
    image_tag (status == 'building' ? "#{status}.gif" : "#{status}.png"), :alt => status, :title => status
  end
end

