class SelectSuggestedSolutionsForMentor
  include Mandate

  MAX_RESULTS = 20

  attr_reader :user, :filtered_track_ids, :filtered_exercise_ids, :triaged_as, :page
  def initialize(user, filtered_track_ids: nil, filtered_exercise_ids: nil, triaged_as: nil, page: nil)
    @user = user
    @page = page
    @filtered_track_ids = filtered_track_ids
    @filtered_exercise_ids = filtered_exercise_ids
    @triaged_as = triaged_as
  end

  def call
    solution_ids = select_new_core
    solution_ids += select_legacy_core(MAX_RESULTS - solution_ids.length)
    solution_ids += select_new_side(MAX_RESULTS - solution_ids.length)
    solution_ids += select_legacy_side(MAX_RESULTS - solution_ids.length)
    solution_ids += select_independent(MAX_RESULTS - solution_ids.length)
    solution_ids += select_rest(solution_ids, MAX_RESULTS - solution_ids.length)

    Solution.
      where(id: solution_ids).
      order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(",")}')")).
      includes(iterations: [], exercise: {track: []}, user: [:profile, { avatar_attachment: :blob }])
  end

  private

  def select_new_core
    base_mentored_mode_new_query.
      where('exercises.core': true).
      limit(MAX_RESULTS).pluck(:id)
  end

  def select_new_side(limit)
    base_mentored_mode_new_query.
      where('exercises.core': false).
      limit(limit).pluck(:id)
  end

  def select_legacy_core(limit)
    base_mentored_mode_legacy_query.
      where('exercises.core': true).
      limit(limit).pluck(:id)
  end

  def select_legacy_side(limit)
    base_mentored_mode_legacy_query.
      where('exercises.core': false).
      limit(limit).pluck(:id)
  end

  def select_independent(limit)
    base_query.
      where("solutions.track_in_independent_mode": true).
      order(Arel.sql("last_updated_by_user_at ASC")).
      limit(limit).pluck(:id)
  end

  def select_rest(ignore_ids, limit)
    base_query.
      where.not(id: ignore_ids).
      order(Arel.sql("last_updated_by_user_at ASC")).
      limit(limit).pluck(:id)
  end

  def base_mentored_mode_new_query
    base_mentored_mode_query.
      not_legacy
  end

  def base_mentored_mode_legacy_query
    base_mentored_mode_query.
      legacy.
      where("solutions.last_updated_by_user_at > ?", Exercism::V2_MIGRATED_AT.to_s(:db))
  end

  def base_mentored_mode_query
    base_query.
      where("solutions.track_in_independent_mode": false).
      order(Arel.sql("last_updated_by_user_at ASC"))
  end

  def base_query
    bs = Solution.

      # Only relevant exercise_ids
      joins(:exercise).
      where("solutions.exercise_id": exercise_ids).

      # Not things you already mentor
      where.not(id: user.solution_mentorships.select(:solution_id)).

      # Not things you've ignored
      where.not(id: user.ignored_solution_mentorships.select(:solution_id)).

      # Not your own solutions
      where.not(user_id: user.id).

      # Where the person has posted at least one iteration
      where(id: Iteration.select(:solution_id)).

      # Not approved
      where(approved_by: nil).

      # Not completed
      where(completed_at: nil).

      # Where mentoring has been requested
      where.not(mentoring_requested_at: nil).

      # Where there are no mentors
      where(num_mentors: 0).

      # Where not locked by a different mentor
      where("NOT EXISTS(SELECT NULL FROM solution_locks
                        WHERE solution_locks.solution_id = solutions.id
                        AND locked_until > ?
                        AND user_id != ?)", Time.current, user.id)

      bs = bs.where(triaged_as: triaged_as) if triaged_as.present?

      return bs
  end

  memoize
  def exercise_ids
    eids = Exercise.where(track_id: track_ids).select(:id)
    eids = eids.where(id: filtered_exercise_ids) if filtered_exercise_ids.present?
    eids
  end

  memoize
  def track_ids
    tids = user.track_mentorships.select(:track_id)
    tids = tids.where(track_id: filtered_track_ids) if filtered_track_ids.present?
    tids
  end
end
