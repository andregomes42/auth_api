class User < ApplicationRecord
  attr_accessor :password_confirmation

  validates :email, uniqueness: true
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