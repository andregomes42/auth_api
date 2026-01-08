class TokenService
  SECRET_KEY = ENV.fetch("JWT_SECRET")
  ALGORITHM = 'HS256'

  def self.encode(user)
    sessionId = SecureRandom.uuid

    refresh_token(user, sessionId)
  end

  private
  
  def self.access_token(user, sessionId)
    payload = payload(user, sessionId, 5.minutes)

    encode_token(payload)
  end

  def self.refresh_token(user, sessionId)
    payload = payload(user, sessionId, 8.hours)

    encode_token(payload)
  end

  def self.payload(user, sessionId, expires_in)
    {
      sid: sessionId,
      jti: SecureRandom.uuid,
      sub: user.email,
      username: user.name,
      iat: Time.now.to_i,
      exp: expires_in.from_now.to_i
    }
  end

  def self.encode_token(payload)
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode_token(token)
    JWT.decode(token, SECRET_KEY, ALGORITHM)
  end
end
