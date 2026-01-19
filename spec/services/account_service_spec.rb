require 'rails_helper'

RSpec.describe AccountService, type: :service do
  describe '.signup' do
    context 'with valid attributes' do
      it 'creates a new user and returns success' do
        payload = attributes_for(:user)

        response = AccountService.signup(payload)

        expect(response[:success]).to be true
        expect(response[:user]).to be_a(User)
        expect(response[:user]).to be_persisted
        expect(response[:user].id).not_to be_nil
        expect(response[:user].email).to eq(payload[:email])
      end
    end

    context 'with invalid attributes' do
      it 'returns failure when user is invalid' do
        payload = attributes_for(:user, :new)

        response = AccountService.signup(payload)

        expect(response[:success]).to be false
        expect(response[:errors]).to be_present
      end
    end
  end
end
