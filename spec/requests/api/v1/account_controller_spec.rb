require 'rails_helper'

RSpec.describe 'API::V1::AccountController', type: :request do
  describe 'POST /api/v1/signup' do
    context 'with valid params' do
      it 'returns 201' do
        payload = attributes_for(:user)
        user = build(:user, payload)

        post '/api/v1/signup', params: { user: payload }
        body = JSON.parse(response.body)
        
        expect(response).to have_http_status(:created)
        expect(body).not_to have_key('created_at')
        expect(body).not_to have_key('updated_at')
        expect(body).not_to have_key('password')
        expect(body.fetch('id')).to be_a(String)
        expect(body).to include_json(
          'name' => user.name,
          'email' => user.email,
          'birthdate' => user.birthdate.as_json
        )
      end
    end

    context 'with invalid params' do
      it 'returns 422' do
        payload = attributes_for(:user, :new)
        allow(AccountService).to receive(:signup).and_return({ success: false, errors: 'errors' })

        post '/api/v1/signup', params: { user: payload }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include_json(
          status: 422,
          code: 'UNPROCESSABLE_ENTITY',
          message: 'Invalid Params',
          errors: 'errors'
        )
      end
    end
  end
end