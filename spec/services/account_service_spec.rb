require 'rails_helper'

RSpec.describe AccountService, type: :service do
  describe '.signup' do
    context 'with valid attributes' do
      it 'creates a new user' do
        payload = attributes_for(:user)

        response = AccountService.signup(payload)

        expect(response[:success]).to be true
        expect(response[:user]).to be_persisted
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

  describe '.reset_password' do
    context 'with valid attributes' do
      it 'changes user pasword' do
        payload = attributes_for(:user)
        params = attributes_for(:user)
        user = create(:user, params)

        allow(VERSION_LIST).to receive(:incr).with("token:version:uid:#{user.id}")

        response = AccountService.reset_password(user, params[:password], payload[:password])
        user.reload
        
        expect(response[:success]).to be true
        expect(user.password_match(payload[:password])).to be true
        expect(VERSION_LIST).to have_received(:incr).once
      end
    end

    context 'with invalid attributes' do
      it 'returns failure when current password is incorrect' do
        user = create(:user)

        response = AccountService.reset_password(user, user.name, user.email)

        expect(response[:success]).to be false
        expect(response[:errors][:current_password]).to include('passwords don\'t match')
      end
    end
  end
end
