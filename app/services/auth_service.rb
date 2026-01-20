class AuthService
  def self.login(username, password)
    user = User.find_by(email: username)
    
    return { success: false } unless user&.password_match(password)
    
    refresh_token = TokenService.encode(user)
    
    { success: true, token: refresh_token }
  end

  def self.refresh(token)
    access_token = TokenService.refresh(token)
    
    { success: true, token: access_token }
  end

  def self.logout(token)
    ttl = TokenService.extract_exp(token) - Time.now.to_i
    sid = TokenService.extract_sid(token)
    
    REDIS.setex("blacklist:sid:#{sid}", ttl, 1)
  end
end
