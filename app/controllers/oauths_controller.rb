require 'oauth2'
class OauthsController < ApplicationController
  skip_before_filter :require_login

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]
    begin
    if @user = login_from(provider)
      redirect_to root_path, :notice => "Logged in from #{provider.titleize}!"
    else
      begin
        @user = create_from(provider)
        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_to root_path, :notice => "Logged in from #{provider.titleize}!"
      rescue
        raise if Rails.env == "development"
        redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
      end
    end
    rescue ::OAuth2::Error => e
      p e
      puts e.code
      puts e.description
      puts e.message
      puts e.backtrace
    end
  end

  private
  def auth_params
    params.permit(:code, :provider)
  end
end
