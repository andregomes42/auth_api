class ApplicationController < ActionController::API
  before_action :authenticate
  attr_reader :current_user, :token

  def render_success(data:, status:)
    render json: data, status: status
  end

  def render_unprocessable_entity(errors)
    render_error(status: :unprocessable_entity, status_code: 422, code: 'UNPROCESSABLE_ENTITY', message: 'Invalid Params', errors: errors)
  end

  def render_unauthorized(message = 'Unauthorized')
    render_error(status: :unauthorized, status_code: 401, code: 'UNAUTHORIZED', message: message, errors: nil)
  end

  private

    def authenticate
      begin
        authorization = request.headers['Authorization']
        @token = authorization.split(' ').last

        sub = TokenService.validate(@token)
        return render_unauthorized unless sub

        @current_user = User.find_by(id: sub)
        render_unauthorized unless @current_user
      rescue
        render_unauthorized
      end
    end

    def render_error(status:, status_code:, code:, message:, errors:)
      render json: {status: status_code, code: code, message: message, errors: errors}, status: status
    end
end
