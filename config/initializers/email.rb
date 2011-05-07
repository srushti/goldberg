Goldberg::Application.config.action_mailer.delivery_method = :smtp

Goldberg::Application.config.action_mailer.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => 'mail.c42.in',
  :user_name => 'aakash@c42.in',
  :password => 'dh@rm@',
  :authentication => 'plain',
  :enable_starttls_auto => true
}

Goldberg::Application.config.action_mailer.default_url_options = {
  :host => "localhost:3000"
}