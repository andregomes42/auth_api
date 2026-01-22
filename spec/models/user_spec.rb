require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates required attributes presence' do
      user = build(:user, :new)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to include('can\'t be blank')
      expect(user.errors[:email]).to include('can\'t be blank')
      expect(user.errors[:password]).to include('can\'t be blank')
      expect(user.errors[:birthdate]).to include('can\'t be blank')
    end

    it 'validates attributes format' do
      user = build(:user, :invalid)
      
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
      expect(user.errors[:birthdate]).to include("must be less than #{Date.today}")
    end

    it 'validates email uniqueness' do
      user = create(:user)
      new_user = build(:user, email: user.email)
      
      expect(new_user).not_to be_valid
      expect(new_user.errors[:email]).to include('has already been taken')
    end

    it 'validates password minimum length' do
      user = build(:user, :short)
      
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
    end
  end

  describe 'callbacks' do
    it 'encrypts password before save' do
      payload = build(:user)
      user = build(:user, password: payload.password)

      user.save
      
      expect(user.password).not_to eq(payload.password)
      expect(user.password).to start_with('$2a$')
    end
  end

  describe '#password_match' do
    it 'returns true when password matches' do
      payload = build(:user)
      user = create(:user, password: payload.password)
      
      expect(user.password_match(payload.password)).to be true
    end

    it 'returns false when password does not match' do
      user = create(:user)
      
      expect(user.password_match(user.password)).to be false
    end
  end
end