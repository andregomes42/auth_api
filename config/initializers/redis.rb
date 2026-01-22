BLACKLIST = Redis.new(url: "#{ENV.fetch('REDIS_URL')}/0")

VERSION_LIST = Redis.new(url: "#{ENV.fetch('REDIS_URL')}/1")
