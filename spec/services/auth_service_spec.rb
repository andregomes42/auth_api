require 'rails_helper'

RSpec.describe AuthService, type: :service do
  describe '.login' do
    context 'with valid credentials' do
      it 'returns success and generates token' do
        payload = attributes_for(:user)
        user = create(:user, payload)
        
        allow(TokenService).to receive(:encode).with(user).and_return(user.password)

        response = AuthService.login(user.email, payload[:password])

        expect(response[:success]).to be true
        expect(response[:token]).to eq(user.password)
      end
    end

    context 'with invalid credentials' do
      it 'returns failure when user does not exist' do
        response = AuthService.login('nonexistent@example.com', 'password')

        expect(response[:success]).to be false
        expect(response[:token]).not_to be_present
      end

      it 'returns failure when password does not match' do
        user = create(:user)
        password = 'password'

        response = AuthService.login(user.email, password)

        expect(response[:success]).to be false
        expect(response[:token]).not_to be_present
      end
    end
  end

  it '.refresh' do
    token = 'refresh_token'
    new_token = 'new_access_token'
    
    allow(TokenService).to receive(:refresh).with(token).and_return(new_token)

    response = AuthService.refresh(token)

    expect(response[:success]).to be true
    expect(response[:token]).to eq(new_token)
  end

  it '.logout' do
    session_id = '123'
    token = 'access_token'
    exp_time = 1.hour.from_now.to_i
    
    allow(TokenService).to receive(:extract_sid).with(token).and_return(session_id)
    allow(TokenService).to receive(:extract_exp).with(token).and_return(exp_time)
    allow(Time).to receive(:now).and_return(Time.at(exp_time - 3600))
    allow(REDIS).to receive(:setex)

    response = AuthService.logout(token)

    expect(response).to be_nil
    expect(REDIS).to have_received(:setex).with("blacklist:sid:#{session_id}", 3600, 1)
  end
end
