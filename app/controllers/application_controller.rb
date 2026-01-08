class ApplicationController < ActionController::API
  before_action :authenticate
  attr_reader :current_user, :token

  private

  def authenticate
    begin
      authorization = request.headers["Authorization"]
      @token = authorization.split(" ").last

      sub = TokenService.validate(@token)
      return unauthorized unless sub

      @current_user = User.find_by(id: sub)
      unauthorized unless @current_user
    rescue
      unauthorized
    end
  end

  def unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
