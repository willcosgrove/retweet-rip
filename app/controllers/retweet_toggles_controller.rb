class RetweetTogglesController < ApplicationController
  DISABLED_FLASH = <<~END
    You got it, we're disabling retweets on your timeline now. It takes a
    minute, so just calm down. It's also not retroactive, so you'll only notice
    the changes for tweets going forward. It can take a few minutes depending on
    how many people you follow, and how backed up we are
  END

  ENABLED_FLASH = <<~END
    Not for you huh? We're enabling retweets on your timeline now. You probably
    know the drill by now but just to recap: it takes a minute, and it's not
    retroactive. Try not to think about all the fascinating retweets you've
    missed.
  END

  def index
  end

  def create
    if auth_hash.present?
      RetweetSetterJob.perform_later(
        auth_hash.credentials.token,
        auth_hash.credentials.secret,
        enable_retweets?,
      )
      notice = session.delete(:retweets) ? ENABLED_FLASH : DISABLED_FLASH
      redirect_to '/', notice: notice
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
