class UsersController < ApplicationController
  def new
  end

  def signin
    redirect_to "#{GITHUB_CONFIG['authorize_url'] % GITHUB_CONFIG['client_id']}"
  end

  def signout
    session.delete('user')
    redirect_to root_path
  end

  def github_callback
    access_token = Github.get_oauth_token(params['code'])
    if access_token
      set_current_user(Github.get_login(access_token))
    end
    redirect_to root_path
  end
end