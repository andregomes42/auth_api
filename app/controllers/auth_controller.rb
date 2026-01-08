class AuthController < ApplicationController
  skip_before_action :authenticate, only: [:login]

  def login
    payload = params.require(:user).permit(:username, :password)
    user = User.find_by(email: payload.fetch(:username)) 

    if user&.password_match(payload.fetch(:password))
      token = TokenService.encode(user)

      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
