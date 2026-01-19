class AccountService
  def self.signup(payload)
    user = User.new(payload)
    
    return { success: false, errors: user.errors } unless user.valid?
    return { success: false, errors: user.errors } unless user.save
    
    { success: true, user: user }
  end
end