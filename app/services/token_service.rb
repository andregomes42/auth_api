class TokenService
  SECRET_KEY = ENV.fetch('JWT_SECRET')
  ALGORITHM = 'HS256'

  def self.encode(user)
    token_version = RedisService.get_version(user.id)
    session_id = SecureRandom.uuid

    unless token_version
      RedisService.add_version(user.id)
      token_version = '1'
    end

    refresh_token(user.id, session_id, token_version)
  end

  def self.validate(token)
    token = decode_token(token)
    user_id = token.fetch('sub')
    version = RedisService.get_version(user_id)
    blacklisted = RedisService.is_blacklisted(token.fetch('sid'))

    return nil if token.fetch('ver') != version
    return nil if blacklisted == 1

    user_id
  end

  def self.refresh(token)
    token = decode_token(token)

    user_id = token.fetch('sub')
    session_id = token.fetch('sid')
    version = token.fetch('ver')
    
    access_token(user_id, session_id, version)
  end

  def self.extract_sid(token)
    token = decode_token(token)

    token.fetch('sid')
  end

  def self.extract_exp(token)
    token = decode_token(token)

    token.fetch('exp')
  end

  def self.extract_version(token)
    token = decode_token(token)

    token.fetch('ver')
  end

  def self.decode(token)
    decode_token(token)
  end

  private
  
    def self.access_token(user_id, session_id, version)
      payload = payload(user_id, session_id, version, 5.minutes)

      encode_token(payload)
    end

    def self.refresh_token(user_id, session_id, version)
      payload = payload(user_id, session_id, version, 8.hours)

      encode_token(payload)
    end

    def self.payload(user_id, session_id, version, expires_in)
      {
        sid: session_id,
        jti: SecureRandom.uuid,
        ver: version,
        sub: user_id,
        iat: Time.now.to_i,
        exp: expires_in.from_now.to_i
      }
    end

    def self.encode_token(payload)
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def self.decode_token(token)
      JWT.decode(token, SECRET_KEY, ALGORITHM).first
    end
end
