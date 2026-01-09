class AccountController < ApplicationController
  skip_before_action :authenticate, only: [:signup]

  def signup
    payload = params.require(:user).permit(:email, :name, :birthdate, :password, :password_confirmation)
    result = AccountService.signup(payload)
    
    if result[:success]
      render json: result[:user], status: :created
    else
      render json: result[:errors], status: :unprocessable_entity
    end
  end
end
