require 'rails_helper'

RSpec.describe TokenService, type: :service do
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  describe '.encode' do
    it 'generates a refresh token with user id and session id' do
      refresh_token = TokenService.encode(user)

      decoded = TokenService.decode(refresh_token)

      expect(decoded.fetch('sid')).to be_present
      expect(decoded.fetch('jti')).to be_present
      expect(decoded.fetch('sub')).to eq(user_id)
      expect(decoded.fetch('iat')).to be <= Time.now.to_i
      expect(decoded.fetch('exp')).to be <= 8.hours.from_now.to_i
      expect(decoded.fetch('exp')).to be >= 8.hours.from_now.to_i - 10 
    end

    it 'generates unique session id for each token' do
      token1 = TokenService.encode(user)
      token2 = TokenService.encode(user)

      decoded1 = TokenService.extract_sid(token1)
      decoded2 = TokenService.extract_sid(token2)

      expect(decoded1).not_to eq(decoded2)
    end
  end

  describe '.validate' do
    context 'with valid token' do
      it 'returns user id when token is valid and not blacklisted' do
        token = TokenService.encode(user)
        allow(REDIS).to receive(:get).and_return(nil)

        response = TokenService.validate(token)

        expect(response).to eq(user_id)
      end

      it 'returns nil when token is blacklisted' do
        token = TokenService.encode(user)
        decoded = TokenService.decode(token)
        session_id = decoded.fetch('sid')
        
        allow(REDIS).to receive(:get).with("blacklist:sid:#{session_id}").and_return('1')

        response = TokenService.validate(token)

        expect(response).to be_nil
      end
    end

    context 'with invalid token' do
      it 'raises error when token is malformed' do
        token = 'invalid.token.here'

        expect { TokenService.validate(token) }.to raise_error(JWT::DecodeError)
      end

      it 'raises error when token is signed with wrong secret' do
        token = JWT.encode({ sub: user_id }, 'wrong_secret', TokenService::ALGORITHM)

        expect { TokenService.validate(token) }.to raise_error(JWT::VerificationError)
      end

      it 'raises error when token is expired' do
        payload = { sub: user_id, exp: 1.hour.ago.to_i, iat: 2.hours.ago.to_i }
        token = JWT.encode(payload, TokenService::SECRET_KEY, TokenService::ALGORITHM)

        expect { TokenService.validate(token) }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  describe '.refresh' do
    it 'generates new access token' do
      refresh_token = TokenService.encode(user)
      decoded = TokenService.decode(refresh_token)
      session_id = decoded.fetch('sid')

      access_token = TokenService.refresh(refresh_token)
      new_decoded = TokenService.decode(access_token)

      expect(new_decoded.fetch('sub')).to eq(user_id)
      expect(new_decoded.fetch('sid')).to eq(session_id)
      expect(new_decoded.fetch('jti')).not_to eq(decode.fetch('jti'))
      expect(decoded.fetch('exp')).to be <= 5.minutes.from_now.to_i
      expect(decoded.fetch('exp')).to be >= 5.minutes.from_now.to_i - 10
    end

    it 'raises error when refresh token does not have required fields' do
      incomplete_payload = { sub: user_id }
      incomplete_token = JWT.encode(incomplete_payload, TokenService::SECRET_KEY, TokenService::ALGORITHM)

      expect { TokenService.refresh(incomplete_token) }.to raise_error(KeyError)
    end
  end

  it 'extracts session id from token' do
    token = TokenService.encode(user)
    expected_session_id = TokenService.decode(token).fetch('sid')

    result = TokenService.extract_sid(token)

    expect(result).to eq(expected_session_id)
  end

  it '.extract_exp' do
    token = TokenService.encode(user)
    expected_exp = TokenService.decode(token).fetch('exp')

    result = TokenService.extract_exp(token)

    expect(result).to eq(expected_exp)
  end
end
