class AuthService
  def self.login(username, password)
    user = User.find_by(email: username)
    
    return { success: false, error: "Invalid credentials" } unless user&.password_match(password)
    
    token = TokenService.encode(user)
    
    { success: true, token: token }
  end

  def self.refresh(token)
    new_token = TokenService.refresh(token)
    
    { success: true, token: new_token }
  end

  def self.logout(token)
    ttl = TokenService.extract_exp(token) - Time.now.to_i
    sid = TokenService.extract_sid(token)
    
    REDIS.setex("blacklist:sid:#{sid}", ttl, 1)
    
    { success: true }
  end
end