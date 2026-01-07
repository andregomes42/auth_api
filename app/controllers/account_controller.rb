class AccountController < ApplicationController
    def sign_up
        payload = user_params
        @user = User.new(payload.except(:password_confirmation))
        
        passwords_match(payload[:password], payload[:password_confirmation])
        
        if @user.errors.empty? && @user.save
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    private

    def passwords_match(password, password_confirmation)
        return if password == password_confirmation

        @user.errors.add(:password_confirmation, "passwords don't match")
    end

    def user_params
        params.require(:user).permit(:email, :name, :birthdate, :password, :password_confirmation)
    end
end
