class TokenService
  SECRET_KEY = ENV.fetch("JWT_SECRET")
  ALGORITHM = 'HS256'

  def self.encode(user)
    session_id = SecureRandom.uuid

    refresh_token(user.id, session_id)
  end

  def self.refresh(token)
    token = decode_token(token)

    user_id = token.fetch("sub")
    session_id = token.fetch("sid")
    
    access_token(user_id, session_id)
  end

  def self.validate(token)
    now = Time.now.to_i
    token = decode_token(token)
    expiration = token.fetch("exp")

    return nil unless expiration > now 

    token.fetch("sub") 
  end

  private
  
  def self.access_token(user_id, session_id)
    payload = payload(user_id, session_id, 5.minutes)

    encode_token(payload)
  end

  def self.refresh_token(user_id, session_id)
    payload = payload(user_id, session_id, 8.hours)

    encode_token(payload)
  end

  def self.payload(user_id, session_id, expires_in)
    {
      sid: session_id,
      jti: SecureRandom.uuid,
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
