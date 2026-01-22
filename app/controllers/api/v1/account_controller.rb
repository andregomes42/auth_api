module Api
  module V1
    class AccountController < ApplicationController
      skip_before_action :authenticate, only: [:signup]

      def signup
        payload = params.require(:user).permit(:email, :name, :birthdate, :password, :password_confirmation)
        response = AccountService.signup(payload)

        if response[:success]
          render_success(data: UserSerializer.new(response[:user]).as_json, status: :created)
        else
          render_unprocessable_entity(response[:errors])
        end
      end

      def reset_password
        payload = params.require(:user).permit(:current_password, :new_password)
        response = AccountService.reset_password(@current_user, payload[:current_password], payload[:new_password])

        if response[:success]
          head :no_content
        else
          render_unprocessable_entity(response[:errors])
        end
      end
    end
  end
end
