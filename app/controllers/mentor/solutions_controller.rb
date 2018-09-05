class Mentor::SolutionsController < MentorController
  before_action :set_solution
  before_action :check_mentor_may_mentor_solution!

  def show
    if current_user == @solution.user
      return redirect_to [:my, @solution]
    end

    @exercise = @solution.exercise
    @track = @exercise.track

    @iteration = @solution.iterations.offset(params[:iteration_idx].to_i - 1).first if params[:iteration_idx].to_i > 0
    @iteration = @solution.iterations.last unless @iteration

    @comments = @solution.reactions.with_comments.includes(user: [:profile, { avatar_attachment: :blob }])
    @reaction_counts = @solution.reactions.group(:emotion).count.to_h
    @solution_user_track = UserTrack.where(user: @solution.user, track: @track).first

    @user_tracks = UserTrack.where(track: @track, user_id: @iteration.discussion_posts.map(&:user_id)).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }

    @current_user_lock = SolutionLock.find_by(solution: @solution, user: current_user)

    ClearNotifications.(current_user, @solution)
    ClearNotifications.(current_user, @iteration)
  end

  def approve
    ApproveSolution.(@solution, current_user)
  end

  def ignore
    IgnoredSolutionMentorship.find_or_create_by(user: current_user, solution: @solution)
    redirect_to [:mentor, :dashboard]
  end

  def abandon
    @mentor_solution = SolutionMentorship.where(user: current_user, solution: @solution).first
    if @mentor_solution.nil?
      @mentor_solution = CreateSolutionMentorship.(@solution, current_user)
    end
    @mentor_solution.update(abandoned: true)
    redirect_to [:mentor, :dashboard]
  end

  def lock
    @solution_locked = LockSolution.(current_user, @solution, force: !!params[:force])

    respond_to do |format|
      format.js
      format.html { redirect_to action: :show }
    end
  end

  def report
    render_modal("mentor-solution-report", "report")
  end

  def report_send
    CoCReport.create!(user: current_user, solution_uuid: @solution.uuid, report_text: params[:report_text])
    render_modal("mentor-solution-report-send", "report_send")
  end

  private

  def set_solution
    @solution = Solution.find_by_uuid!(params[:id])
  end

  def check_mentor_may_mentor_solution!
    return head 403 if current_user == @solution.user

    return true if current_user.mentoring_solution?(@solution)
    return true if current_user.mentoring_track?(@solution.exercise.track)

    head 403
  end
end
