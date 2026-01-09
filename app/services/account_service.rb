class AccountService
  def self.signup(user_params)
    password = user_params[:password]
    password_confirmation = user_params[:password_confirmation]
    
    user = User.new(user_params.except(:password_confirmation))
    
    validate_passwords_match(user, password, password_confirmation)
    
    return { success: false, errors: user.errors } unless user.errors.empty?
    return { success: false, errors: user.errors } unless user.save
    
    { success: true, user: user }
  end

  private

  def self.validate_passwords_match(user, password, password_confirmation)
    return if password == password_confirmation

    user.errors.add(:password_confirmation, "passwords don't match")
  end
end
