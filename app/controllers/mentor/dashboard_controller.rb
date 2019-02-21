class Mentor::DashboardController < MentorController
  def show
    redirect_to action: :your_solutions
  end

  def your_solutions
    load_your_solutions
    respond_to do |format|
      format.js
      format.html do
        load_general_stats
        load_tab_stats
      end
    end
  end

  def next_solutions
    return redirect_to mentor_configure_path unless current_user.mentored_tracks.exists?

    load_next_solutions
    respond_to do |format|
      format.js
      format.html do
        load_track_stats
        load_tab_stats
      end
    end
  end

  private

  def load_your_solutions
    @your_status = params[:your_status]
    @your_status_options = SolutionMentorship::STATUSES

    @your_track_id = params[:your_track_id].presence || single_track_id
    @your_track_id_options = track_id_options

    @your_exercise_id = params[:your_exercise_id]
    @your_exercise_id_options = exercise_id_options_for(@your_track_id)

    @your_solutions = RetrieveSolutionsForMentor.(
      current_user,
      status: @your_status,
      track_id: @your_track_id,
      exercise_id: @your_exercise_id
    ).page(params[:page]).per(20)

    user_ids = @your_solutions.map(&:user_id)
    @user_tracks = UserTrack.where(user_id: user_ids).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }
  end

  def load_general_stats
    @total_solutions_count = current_user.solution_mentorships.count
    @total_students_count = current_user.mentored_solutions.select(:user_id).distinct.count
    @weekly_solutions_count = current_user.solution_mentorships.where("solution_mentorships.created_at > ?", Time.now.beginning_of_week).count
    @feedbacks = current_user.solution_mentorships.where(show_feedback_to_mentor: true).order('updated_at desc').limit(5).pluck(:feedback)

    if current_user.num_rated_mentored_solutions >= Exercism::MENTOR_RATING_THRESHOLD
      @rating_threshold_reached = true
      @mentor_rating = current_user.mentor_rating
    end
  end

  def load_next_solutions
    @next_track_id = params[:next_track_id].presence || first_track_id
    @next_track = Track.find(@next_track_id)
    @next_track_id_options = track_id_options

    @next_exercise_id = params[:next_exercise_id]

    @next_solutions = SelectSuggestedSolutionsForMentor.(
      current_user,
      filtered_track_ids: @next_track_id,
      filtered_exercise_ids: @next_exercise_id
    ).to_a

    user_ids = @next_solutions.map(&:user_id)
    @user_tracks = UserTrack.where(user_id: user_ids).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }
  end

  def load_track_stats
    service = SolutionsToBeMentored.new(current_user, @next_track_id, nil)
    core_counts = service.core_solutions.group(:exercise_id).count
    @core_exercise_counts = @next_track.exercises.core.
      map{|e| [e, core_counts[e.id].to_i]}.
      sort_by {|e,c|e.position}
    @total_core_count = @core_exercise_counts.map(&:second).sum

    side_counts = service.side_solutions.group(:exercise_id).count
    @side_exercise_counts = @next_track.exercises.where(id: side_counts.map(&:first)).
      map{|e| [e, side_counts[e.id].to_i]}.
      sort_by {|e,c|e.slug}
    @total_side_count = @side_exercise_counts.map(&:second).sum
    @total_count = @total_core_count + @total_side_count

    @total_core_count
  end

  def load_tab_stats
    @tab_your_count = RetrieveSolutionsForMentor.(current_user).count
    @tab_next_count = SolutionsToBeMentored.new(current_user, nil, nil).all_solutions.count
  end

  def track_id_options
    @track_id_options ||=
      OptionsHelper.as_options(current_user.mentored_tracks, :title, :id)
  end

  def single_track_id
    first_track_id if track_id_options.one?
  end

  def first_track_id
    track_id_options.first[:value]
  end

  def exercise_id_options_for(track_id)
    track = Track.find_by(id: track_id)
    return [] unless track

    OptionsHelper.as_options(track.exercises.reorder(:title), :title, :id, include_blank: true)
  end
end
