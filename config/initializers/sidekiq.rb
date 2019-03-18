redis_options_hash =
  case Rails.env
  when 'production'
    { url: "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379/0", namespace: "track_status" }
  when 'development'
    { url: "redis://#{ENV['REDIS_HOST']}:6379/0", namespace: "track_status" }
  end
Sidekiq.configure_server do |config|
  config.redis = redis_options_hash
end

Sidekiq.configure_client do |config|
  config.redis = redis_options_hash
end
