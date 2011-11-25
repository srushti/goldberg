class ApplicationController < ActionController::Base
  protect_from_forgery


  helper_method :current_user

  def current_user
    User.find_by_login(session['user'])
  end

  def set_current_user(login)
    session['user'] = login
    if User.find_by_login(login).nil?
      User.create(:login => login)
    end
  end

  def authenticate_user
    if current_user.blank?
      redirect_to new_user_path
    end
  end

end
