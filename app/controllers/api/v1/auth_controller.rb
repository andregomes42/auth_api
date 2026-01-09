module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate, only: [:login]

      def login
        payload = params.require(:user).permit(:username, :password)
        result = AuthService.login(payload[:username], payload[:password])

        if result[:success]
          render json: { token: result[:token] }, status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end

      def refresh
        result = AuthService.refresh(@token)

        render json: { token: result[:token] }, status: :ok
      end

      def logout
        AuthService.logout(@token)

        head :no_content
      end
    end
  end
end
