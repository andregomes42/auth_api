class AccountService
  def self.signup(user_params)
    user = User.new(user_params)
    
    return { success: false, errors: user.errors } unless user.valid?
    return { success: false, errors: user.errors } unless user.save
    
    { success: true, user: user }
  end
end