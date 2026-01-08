class User < ApplicationRecord
  self.table_name = 'auth.users'

  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: "must be a valid email"}
  validates :password, presence: true, length: { minimum: 8 }

  before_save :encode

  private

  def encode
    self.password = BCrypt::Password.create(password)
  end
end
