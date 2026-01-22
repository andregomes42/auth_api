class User < ApplicationRecord

  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 8 }
  validates :email, presence: true, email: true, uniqueness: true
  validates :birthdate, presence: true, comparison: { less_than: Date.today }

  before_save :encode

  def password_match(password)
    BCrypt::Password.new(self.password) == password
  end

  private

    def encode
      self.password = BCrypt::Password.create(password)
    end
end