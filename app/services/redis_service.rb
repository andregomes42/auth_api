class RedisService
  BLACKLIST_PREFIX = 'blacklist:sid'
  VERSION_PREFIX = 'token:version:uid'

  def self.add_to_blacklist(sid, ttl)
    BLACKLIST.setex("#{BLACKLIST_PREFIX}:#{sid}", ttl, 1)
  end

  def self.is_blacklisted(sid)
    BLACKLIST.exists("#{BLACKLIST_PREFIX}:#{sid}")
  end

  def self.get_version(user_id)
    VERSION_LIST.get("#{VERSION_PREFIX}:#{user_id}")
  end

  def self.add_version(user_id)
    VERSION_LIST.set("#{VERSION_PREFIX}:#{user_id}", 1)
  end

  def self.increment_version(user_id)
    VERSION_LIST.incr("#{VERSION_PREFIX}:#{user_id}")
  end
end
