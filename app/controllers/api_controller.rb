class APIController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  rescue_from ActionController::RoutingError, with: -> { render_404  }

  layout false
  
  def a 
    "a"
  end

  def authenticate_user!
    authenticate_with_http_token do |token, options|
      break unless token.present?

      user = AuthToken.find_by(token: token).try(:user)
      break unless user

      sign_in(user) and return
    end

    render_401
  end

  def render_401
    render json: {}, status: 401
  end

  def render_403(type)
    render_error(403, type)
  end

  def render_404(type = :resource_not_found, data = {})
    render_error(404, type, data)
  end

  def render_solution_not_found
    render_404(:solution_not_found)
  end

  def render_solution_not_accessible
    render_403(:solution_not_accessible)
  end

  def render_error(status, type, data = {})
    message = I18n.t("api.errors.#{type}")

    render json: {
      error: {
        type: type,
        message: message
      }.merge(data)
    }, status: status
  end
end
