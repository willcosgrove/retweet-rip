class RetweetDisablerJob < ApplicationJob
  queue_as :default

  def perform(access_token, access_secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_API_KEY"]
      config.consumer_secret     = ENV["TWITTER_API_SECRET"]
      config.access_token        = access_token
      config.access_token_secret = access_secret
    end

    client.friend_ids.each do |friend_id|
      client.friendship_update(friend_id, { retweets: false })
    end
  end
end
