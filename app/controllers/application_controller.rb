class ApplicationController < ActionController::API
  before_action :authenticate
  attr_reader :current_user, :token

  private

  def authenticate
    begin
      authorization = request.headers["Authorization"]
      @token = authorization.split(" ").last

      sub = TokenService.validate(@token)
      return render_unauthorized unless sub

      @current_user = User.find_by(id: sub)
      render_unauthorized unless @current_user
    rescue
      render_unauthorized
    end
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
