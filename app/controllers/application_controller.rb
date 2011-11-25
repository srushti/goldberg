class ApplicationController < ActionController::Base
  protect_from_forgery


  helper_method :current_user, :authenticate_user

  private

  def authenticate_user
    if current_user.blank?
      redirect_to new_user_path
    end
  end

  def current_user
    session['user']
  end
end
