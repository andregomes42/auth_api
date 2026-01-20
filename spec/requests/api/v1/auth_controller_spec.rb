require 'rails_helper'

RSpec.describe 'API::V1::AuthController', type: :request do
  describe 'POST /api/v1/login' do
    context 'with valid credentials' do
      it 'returns 200' do
        payload = attributes_for(:user)
        user = build(:user, payload)
        token = 'refresh_token'

        allow(AuthService).to receive(:login).with(payload[:email], payload[:password])
          .and_return({ success: true, token: token })

        post '/api/v1/login', params: { user: { username: payload[:email], password: payload[:password] } }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include_json(token: token)
      end
    end

    context 'with invalid credentials' do
      it 'returns 401' do
        payload = attributes_for(:user)

        allow(AuthService).to receive(:login).with(payload[:email], payload[:password])
          .and_return({ success: false})

        post '/api/v1/login', params: { user: { username: payload[:email], password: payload[:password] } }

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include_json(
          status: 401,
          code: 'UNAUTHORIZED',
          message: 'Invalid Credentials',
          errors: nil
        )
      end
    end
  end

  describe 'PATCH /api/v1/refresh' do
    context 'with valid token' do
      it 'returns 200' do
        refresh_token = 'refresh_token'
        new_token = 'access_token'
        user = create(:user)

        allow(TokenService).to receive(:validate).with(refresh_token).and_return(user.id)
        allow(AuthService).to receive(:refresh).with(refresh_token)
          .and_return({ success: true, token: new_token })

        patch '/api/v1/refresh', headers: { 'Authorization' => "Bearer #{refresh_token}" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include_json(token: new_token)
      end
    end

    context 'with invalid token' do
      it 'returns 401' do
        allow(TokenService).to receive(:validate).and_return(nil)

        patch '/api/v1/refresh', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/logout' do
    context 'with authentication' do
      it 'returns 204' do
        user = create(:user)
        token = 'valid_token'

        allow(TokenService).to receive(:validate).with(token).and_return(user.id)
        allow(AuthService).to receive(:logout).with(token).and_return(nil)

        delete '/api/v1/logout', headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'without authentication' do
      it 'returns 401' do
        allow(TokenService).to receive(:validate).and_return(nil)

        delete '/api/v1/logout'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end