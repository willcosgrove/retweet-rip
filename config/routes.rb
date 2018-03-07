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

  root to: 'retweet_toggles#index'
end
