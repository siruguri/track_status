redis_options_hash =
  case Rails.env
  when 'production'
    { url: "redis://:thisisverysecureok@#{ENV['REDIS_HOST']}:6379/0", namespace: "track_status" }
  when 'development'
    { url: "redis://#{ENV['REDIS_HOST']}:6379/0", namespace: "track_status" }
  end

unless Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = redis_options_hash
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_options_hash
  end
end
