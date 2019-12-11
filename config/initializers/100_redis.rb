def redis_connection_options
  redis_config = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/redis.yml")).result)[Rails.env].symbolize_keys
  {
      :host => redis_config[:host],
      :port => redis_config[:port],
      :db   => redis_config[:database],
      :timeout => 5
  }
end

def redis_init
  #$redis =  Redis.new(redis_connection_options)
  $redis =  Redis.new(url: ENV['REDIS_CLOUD_URL'])
end
