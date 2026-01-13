class User < ApplicationRecord
  self.table_name = 'auth.users'
  attr_accessor :password_confirmation

  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: "must be a valid email"}
  validates :password, presence: true, length: { minimum: 8 }
  validates_confirmation_of :password

  before_save :encode

  def password_match(password)
    BCrypt::Password.new(self.password) == password
  end

  private

  def encode
    self.password = BCrypt::Password.create(password)
  end
end