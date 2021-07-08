class My::SolutionsController < MyController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  before_action :set_solution, except: [:index, :create, :walkthrough]

  def index
    @solutions = current_user.solutions.completed.includes(exercise: :track)
    if params[:track_id].to_i > 0
      @solutions = @solutions.
        joins(:exercise).
        where("exercises.track_id": params[:track_id])
    end

    track_ids = Exercise.where(id: @solutions.map(&:exercise_id)).distinct.pluck(:track_id)
    @tracks_for_select = Track.where(id: track_ids).
      map{|l|[l.title, l.id]}.
      unshift(["Any", 0])
    @track = Track.find_by_id(params[:track_id]) if params[:track_id].to_i > 0
  end

  def create
    track = Track.find(params[:track_id])
    user_track = UserTrack.where(user: current_user, track: track).first
    exercise = track.exercises.find(params[:exercise_id])

    if current_user.may_unlock_exercise?(exercise, user_track: user_track)
      solution = CreateSolution.(current_user, exercise)
      redirect_to [:my, solution]
    else
      redirect_to [:my, track]
    end
  end

  def show
    @exercise = @solution.exercise
    ClearNotifications.(current_user, @solution)

    @track = @solution.exercise.track
    @user_track = UserTrack.where(user: current_user, track: @track).first

    if @solution.iterations.size > 0
      show_started
    else
      show_unlocked
    end
  end

  def walkthrough
    @walkthrough = RenderUserWalkthrough.(
      current_user,
      Git::WebsiteContent.head.walkthrough
    )

    respond_to do |format|
      format.js { render_modal("solution-walkthrough", "walkthrough_modal", close_button: true) }
      format.html { redirect_to cli_walkthrough_page_path }
    end
  end

  def request_mentoring
    RequestMentoringOnSolution.(@solution)

    redirect_to action: :show
  end

  def cancel_mentoring_request
    CancelMentoringRequestForSolution.(@solution)

    redirect_to action: :show
  end

  def confirm_unapproved_completion
    render_modal('solution-confirm-unapproved-completion', "confirm_unapproved_completion")
  end

  def complete
    CompleteSolution.(@solution)
    @exercise = @solution.exercise
    @track = @exercise.track
    @num_completed_exercises = current_user.solutions.where(exercise_id: @track.exercises).completed.count
    render_modal("solution-completed", "complete")
  end

  def reflection
    show_reflection_modal
  end

  def reflect
    allow_comments = !!params[:allow_comments]

    @solution.update(reflection: params[:reflection])
    ToggleSolution.(@solution) if params[:publish]
    @solution.update(allow_comments: allow_comments)
    current_user.update(default_allow_comments: allow_comments) if current_user.default_allow_comments === nil

    if @solution.mentorships.count > 0
      show_mentor_ratings_modal
    else
      show_unlocked_modal_or_redirect
    end
  end

  def rate_mentors
    (params[:mentor_reviews] || {}).each do |mentor_id, data|
      ReviewSolutionMentoring.(
        @solution,
        User.find(mentor_id),
        data[:rating],
        data[:feedback]
      )
    end

    show_unlocked_modal_or_redirect
  end

  def publish
    ToggleSolution.(@solution) if params[:publish]
    redirect_to [@solution]
  end

  def unpublish
    ToggleSolution.(@solution) if params[:unpublish]
    redirect_to [:my, @solution]
  end

  def update_exercise
    @solution.update_git_info!
    redirect_to [:my, @solution]
  end

  def toggle_published
    ToggleSolution.(@solution)

    render "toggle"
  end

  def toggle_show_on_profile
    @solution.update(show_on_profile: !@solution.show_on_profile?)
    render "toggle"
  end

  def toggle_allow_comments
    @solution.update(allow_comments: !@solution.allow_comments?)
    respond_to do |format|
      format.html { redirect_to solution_path }
      format.js { render "toggle" }
    end
  end

  private

  def set_solution
    @solution = Solution.find_by_uuid!(params[:id])
    redirect_to @solution unless @solution.user_id == current_user.id
  end

  def show_unlocked
    render :show_unlocked
  end

  def show_started
    @iteration = @solution.iterations.offset(params[:iteration_idx].to_i - 1).first if params[:iteration_idx].to_i > 0
    @iteration = @solution.iterations.last unless @iteration

    @post_user_tracks = UserTrack.where(user_id: @iteration.discussion_posts.map(&:user_id), track: @track).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }

    if @exercise.core? && @user_track.mentored_mode?
      @queue_position = SolutionsToBeMentored.index_of_core_solution(@solution)
    end

    ClearNotifications.(current_user, @iteration)

    render :show
  end

  def show_reflection_modal
    render_modal("solution-reflection", "reflection")
  end

  def show_mentor_ratings_modal
    @mentor_interations = @solution.discussion_posts.group(:user_id).count
    render_modal("solution-mentor-ratings", "mentor_ratings")
  end

  def show_unlocked_modal_or_redirect
    @track = @solution.exercise.track
    user_track = UserTrack.where(user: current_user, track: @track).first

    if user_track.mentored_mode?
      if @solution.exercise.core?
        @next_core_solution = current_user.solutions.not_completed.
                              includes(exercise: :topics).
                              where("exercises.track_id": @track.id).
                              where("exercises.core": true).
                              first
      end

      @unlocked_side_exercise_solutions = current_user.
        solutions.
        not_completed.
        includes(:exercise).
        where("exercises.id": @solution.exercise.unlocks.side)
    end

    if @next_core_solution || @unlocked_side_exercise_solutions.present?
      render_modal("solution-unlocked", "unlocked")
    else
      js_redirect_to([:my, @solution])
    end
  end
end
