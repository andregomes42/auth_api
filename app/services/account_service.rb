class AccountService
  def self.signup(payload)
    user = User.new(payload)
    
    return { success: false, errors: user.errors } unless user.valid?
    return { success: false, errors: user.errors } unless user.save
    
    { success: true, user: user }
  end

  def self.reset_password(user, current_password, new_password)
    unless user.password_match(current_password)
      user.errors.add(:current_password, 'passwords don\'t match')
    end

    return { success: false, errors: user.errors } unless user.errors.empty?
    return { success: false, errors: user.errors } unless user.update(password: new_password)

    { success: true }
  end
end
