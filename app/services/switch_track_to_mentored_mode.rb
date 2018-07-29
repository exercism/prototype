class SwitchTrackToMentoredMode
  include Mandate

  attr_reader :user, :track
  def initialize(user, track)
    @user = user
    @track = track
  end

  def call
    user_track.update(independent_mode: false)
    user_track.solutions.update_all(track_in_independent_mode: false)

    FixUnlockingInUserTrack.(user_track)

    # Set everything that's not started to mentored mode
    user_track.solutions.update_all(independent_mode: true)
    user_track.solutions.not_started.update_all(independent_mode: false)
  end

  memoize
  def user_track
    user.user_track_for(track)
  end
end
