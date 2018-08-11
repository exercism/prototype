class ProfilesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to action: :index
  end

  before_action :set_profile, except: [:index]

  def show
    @profile_view = ProfilePresenter.new(@profile, track_id: params[:track_id])
  end

  def index
    @profiles = Profile.order("profiles.created_at ASC").includes(:user).page(params[:page]).per(100)
  end

  def solutions
    setup_solutions
  end

  private

  def set_profile
    @user = User.find_by_handle!(params[:id])
    @profile = @user.profile

    raise ActiveRecord::RecordNotFound unless @profile
  end

  def setup_solutions

    @solutions = @profile.solutions.includes(exercise: :track)

    track_ids = Exercise.where(id: @solutions.pluck(:exercise_id)).distinct.pluck(:track_id)
    @tracks_for_select = Track.where(id: track_ids).
      map{|l|[l.title, l.id]}.
      unshift(["Any", 0])
    @track = Track.find_by_id(params[:track_id]) if params[:track_id].to_i > 0

    @solutions = @solutions.joins(:exercise).where("exercises.track_id": @track.id) if @track
    @reaction_counts = Reaction.where(solution_id: @solutions).group(:solution_id, :emotion).count
    @comment_counts = Reaction.where(solution_id: @solutions).with_comments.group(:solution_id).count

    render nothing: true
  end
end
