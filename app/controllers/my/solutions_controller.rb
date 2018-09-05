class My::SolutionsController < MyController
  before_action :set_solution, except: [:create, :walkthrough]

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
    SwitchSolutionToMentoredMode.(@solution)

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
    @mentor_iterations = @solution.discussion_posts.group(:user_id).count
    render_modal("solution-reflection", "reflection")
  end

  def reflect
    @solution.update(reflection: params[:reflection])
    @solution.update(published_at: Time.current) if params[:publish]

    (params[:mentor_reviews] || {}).each do |mentor_id, data|
      ReviewSolutionMentoring.(
        @solution,
        User.find(mentor_id),
        data[:rating],
        data[:feedback]
      )
    end

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

  def publish
    @solution.update(published_at: Time.current) if params[:publish]
    redirect_to [:my, @solution]
  end

  def report
    render_modal("my-solution-report", "report")
  end

  def report_send
    CoCReport.create!(user: current_user, solution_uuid: @solution.uuid, report_text: params[:report_text])
    render_modal("my-solution-report-send", "report_send")
  end

  private

  def set_solution
    @solution = current_user.solutions.find_by_uuid!(params[:id])
  end

  def show_unlocked
    render :show_unlocked
  end

  def show_started
    @iteration = @solution.iterations.offset(params[:iteration_idx].to_i - 1).first if params[:iteration_idx].to_i > 0
    @iteration = @solution.iterations.last unless @iteration

    @post_user_tracks = UserTrack.where(user_id: @iteration.discussion_posts.map(&:user_id), track: @track).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }

    ClearNotifications.(current_user, @iteration)

    render :show
  end
end
