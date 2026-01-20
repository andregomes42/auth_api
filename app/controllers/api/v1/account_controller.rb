module Api
  module V1
    class AccountController < ApplicationController
      skip_before_action :authenticate, only: [:signup]

      def signup
        payload = params.require(:user).permit(:email, :name, :birthdate, :password, :password_confirmation)
        result = AccountService.signup(payload)

        if result[:success]
          render_success(data: UserSerializer.new(result[:user]).as_json, status: :created)
        else
          render_unprocessable_entity(result[:errors])
        end
      end
    end
  end
end
