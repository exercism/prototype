module API
  class ValidateTokenController < BaseController
    def index
      render json: {
        status: {
          token: 'valid',
        }
      }, status: 200
    end
  end
end
