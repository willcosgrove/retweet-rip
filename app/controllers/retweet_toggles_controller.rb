class RetweetTogglesController < ApplicationController
  def index
  end

  def create
    if auth_hash.present?
      RetweetSetterJob.perform_later(
        auth_hash.credentials.token,
        auth_hash.credentials.secret,
        enable_retweets?,
      )
      notice = session.delete(:retweets) ? :enabled_flash : :disabled_flash
      redirect_to '/', notice: I18n.t(notice)
    else
      session[:retweets] = enable_retweets?
      redirect_to '/auth/twitter'
    end
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def enable_retweets?
    params[:retweets].nil? ? session[:retweets] : params[:retweets]
  end
end
