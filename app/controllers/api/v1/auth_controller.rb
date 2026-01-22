module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate, only: [:login]

      def login
        payload = params.require(:user).permit(:username, :password)
        response = AuthService.login(payload[:username], payload[:password])

        if response[:success]
          render_success(data: { token: response[:token] }, status: :ok)
        else
          render_unauthorized('Invalid Credentials')
        end
      end

      def refresh
        response = AuthService.refresh(@token)

        render_success(data: { token: response[:token] }, status: :ok)
      end

      def logout
        AuthService.logout(@token)

        head :no_content
      end
    end
  end
end
