module Research
  class JoinsController < BaseController
    def show
    end

    def create
      current_user.join_research!

      redirect_to research_experiments_path
    end

    private

    def check_user_joined_research!
      redirect_to research_experiments_path if current_user.joined_research?
    end

    def authenticate_user!
      redirect_to root_path if current_user.blank?
    end
  end
end
