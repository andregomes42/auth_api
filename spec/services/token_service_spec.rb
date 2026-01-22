require 'rails_helper'

RSpec.describe TokenService, type: :service do
  let(:user) { create(:user) }

  describe '.encode' do
    it 'generates a refresh token' do
      allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return(nil)
      allow(VERSION_LIST).to receive(:set).with("token:version:uid:#{user.id}", 1)
      
      refresh_token = TokenService.encode(user)
      decoded = TokenService.decode(refresh_token)

      expect(decoded.fetch('ver')).to eq('1')
      expect(decoded.fetch('sid')).to be_present
      expect(decoded.fetch('jti')).to be_present
      expect(decoded.fetch('sub')).to eq(user.id)
      expect(decoded.fetch('iat')).to be <= Time.now.to_i
      expect(decoded.fetch('exp')).to be <= 8.hours.from_now.to_i
      expect(decoded.fetch('exp')).to be >= 8.hours.from_now.to_i - 10 
    end

    it 'generates unique session id for each token' do
      allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
      allow(VERSION_LIST).to receive(:set).with("token:version:uid:#{user.id}", 1)

      token1 = TokenService.encode(user)
      token2 = TokenService.encode(user)
      sid1 = TokenService.extract_sid(token1)
      sid2 = TokenService.extract_sid(token2)

      expect(sid1).not_to eq(sid2)
      expect(VERSION_LIST).to have_received(:set).exactly(0).times
    end
  end

  describe '.validate' do
    context 'with valid token' do
      it 'returns user id when token is valid and not blacklisted' do
        allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
        token = TokenService.encode(user)

        response = TokenService.validate(token)

        expect(response).to eq(user.id)
      end

      it 'returns nil when token is blacklisted' do
        allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
        token = TokenService.encode(user)
        decoded = TokenService.decode(token)
        
        session_id = decoded.fetch('sid')
        allow(BLACKLIST).to receive(:exists).with("blacklist:sid:#{session_id}").and_return(1)
        
        response = TokenService.validate(token)

        expect(response).to be_nil
      end

      it 'returns nil when token has an invalid version' do
        token = TokenService.encode(user)
        
        allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('2')
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
        token = JWT.encode({ sub: user.id }, 'wrong_secret', TokenService::ALGORITHM)

        expect { TokenService.validate(token) }.to raise_error(JWT::VerificationError)
      end

      it 'raises error when token is expired' do
        payload = { sub: user.id, exp: 1.hour.ago.to_i, iat: 2.hours.ago.to_i }
        token = JWT.encode(payload, TokenService::SECRET_KEY, TokenService::ALGORITHM)

        expect { TokenService.validate(token) }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  describe '.refresh' do
    it 'generates new access token' do
      allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')

      refresh_token = TokenService.encode(user)
      decoded = TokenService.decode(refresh_token)
      access_token = TokenService.refresh(refresh_token)
      new_decoded = TokenService.decode(access_token)
      session_id = decoded.fetch('sid')
      version = decoded.fetch('ver')

      expect(new_decoded.fetch('ver')).to eq(version)
      expect(new_decoded.fetch('sub')).to eq(user.id)
      expect(new_decoded.fetch('sid')).to eq(session_id)
      expect(new_decoded.fetch('jti')).not_to eq(decoded.fetch('jti'))
      expect(new_decoded.fetch('exp')).to be <= 5.minutes.from_now.to_i
      expect(new_decoded.fetch('exp')).to be >= 5.minutes.from_now.to_i - 10
    end

    it 'raises error when refresh token does not have required fields' do
      incomplete_payload = { sub: user.id }
      incomplete_token = JWT.encode(incomplete_payload, TokenService::SECRET_KEY, TokenService::ALGORITHM)

      expect { TokenService.refresh(incomplete_token) }.to raise_error(KeyError)
    end
  end

  it 'extracts session id from token' do
    allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
    token = TokenService.encode(user)
    expected_session_id = TokenService.decode(token).fetch('sid')

    response = TokenService.extract_sid(token)

    expect(response).to eq(expected_session_id)
  end

  it '.extract_exp' do
    allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
    
    token = TokenService.encode(user)
    expected_exp = TokenService.decode(token).fetch('exp')

    response = TokenService.extract_exp(token)

    expect(response).to eq(expected_exp)
  end

  it '.extract_version' do
    allow(VERSION_LIST).to receive(:get).with("token:version:uid:#{user.id}").and_return('1')
    token = TokenService.encode(user)

    response = TokenService.extract_version(token)

    expect(response).to eq('1')
  end
end
