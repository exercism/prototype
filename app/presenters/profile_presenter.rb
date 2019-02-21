class ProfilePresenter
  include Mandate

  attr_reader :profile, :track_id

  def initialize(profile, track_id: nil)
    @profile = profile
    @track_id = track_id.to_i > 0 ? track_id.to_i : nil
  end

  memoize
  def solutions
    unfiltered_solutions

    if track_id
      unfiltered_solutions.
        joins(:exercise).
        where("exercises.track_id": track_id)
    else
      unfiltered_solutions
    end
  end

  memoize
  def tracks_for_select
    track_ids = Exercise.
      where(id: unfiltered_solutions.map(&:exercise_id)).
      distinct.
      pluck(:track_id)

    Track.where(id: track_ids).
      map{|l|[l.title, l.id]}.
      unshift(["Any", 0])
  end

  private

  delegate :user, to: :profile

  memoize
  def unfiltered_solutions
    solutions = profile.solutions.
                        published.
                        on_profile.
                        includes(exercise: :track)

  end
end
