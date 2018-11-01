class Mentor::DashboardController < MentorController
  def show
    load_your_solutions
    load_next_solutions

    user_ids = @your_solutions.map(&:user_id) + @next_solutions.map(&:user_id)
    @user_tracks = UserTrack.where(user_id: user_ids).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }

    @total_solutions_count = current_user.solution_mentorships.count
    @total_students_count = current_user.mentored_solutions.select(:user_id).distinct.count
    @weekly_solutions_count = current_user.solution_mentorships.where("solution_mentorships.created_at > ?", Time.now.beginning_of_week).count
    @feedbacks = current_user.solution_mentorships.where(show_feedback_to_mentor: true).order('updated_at desc').limit(5).pluck(:feedback)
  end

  def your_solutions
    load_your_solutions
  end

  def next_solutions
    load_next_solutions
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
    ).to_a

    user_ids = @your_solutions.map(&:user_id)
    @user_tracks = UserTrack.where(user_id: user_ids).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }
  end

  def load_next_solutions
    @next_triaged_as = params[:next_triaged_as]

    @next_track_id = params[:next_track_id].presence || single_track_id
    @next_track_id_options = track_id_options

    @next_exercise_id = params[:next_exercise_id]
    @next_exercise_id_options = exercise_id_options_for(@next_track_id)

    @next_solutions = SelectSuggestedSolutionsForMentor.(
      current_user,
      filtered_track_ids: @next_track_id,
      filtered_exercise_ids: @next_exercise_id,
      triaged_as: @next_triaged_as,
      page: params[:page]
    ).to_a

    user_ids = @next_solutions.map(&:user_id)
    @user_tracks = UserTrack.where(user_id: user_ids).
                             each_with_object({}) { |ut, h| h["#{ut.user_id}|#{ut.track_id}"] = ut }
  end

  def track_id_options
    @track_id_options ||=
      OptionsHelper.as_options(current_user.mentored_tracks,
                                                       :title,
                                                       :id)
  end

  def single_track_id
    track_id_options.first[:value] if track_id_options.one?
  end

  def exercise_id_options_for(track_id)
    track = Track.find_by(id: track_id)
    return [] unless track

    OptionsHelper.as_options(track.exercises.reorder(:title), :title, :id, include_blank: true)
  end
end
