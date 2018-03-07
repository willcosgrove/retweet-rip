require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
end if Rails.env.production?

Rails.application.routes.draw do
  get '/retweets/enable',
    to: 'retweet_toggles#create',
    defaults: { retweets: true },
    as: :enable_retweets

  get '/retweets/disable',
    to: 'retweet_toggles#create',
    defaults: { retweets: false },
    as: :disable_retweets

  get '/auth/twitter/callback', to: 'retweet_toggles#create'

  get '/auth/failure', to: redirect { |_params, req|
    req.flash[:alert] = I18n.t(:auth_failure)
    '/'
  }

  mount Sidekiq::Web, at: "/sidekiq"

  root to: 'retweet_toggles#index'
end
