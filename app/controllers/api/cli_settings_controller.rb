module API
  class CLISettingsController < BaseController
    def show
      render json: {}, status: 200
    end
  end
end
