class My::UserTracksController < MyController
  def create
    track = Track.find(params[:track_id])

    if current_user.previously_joined_track?(track)
      user_track = current_user.user_tracks.find_by(track: track)

      user_track.update!(archived_at: nil)
    else
      JoinsTrack.join!(current_user, track)
    end

    redirect_to [:my, track]
  end

  def set_normal_mode
    user_track = current_user.user_tracks.find(params[:id])
    user_track.update(independent_mode: false)
    render js: "window.closeModal()"
  end

  def set_independent_mode
    user_track = current_user.user_tracks.find(params[:id])
    track = user_track.track
    user_track.update(independent_mode: true)
    redirect_to [:my, track]
  end

  def leave
    user_track = current_user.user_tracks.find(params[:id])

    user_track.update!(archived_at: Time.current)

    redirect_to my_tracks_path
  end
end
