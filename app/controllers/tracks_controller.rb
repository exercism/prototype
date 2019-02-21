class TracksController < ApplicationController
  def index
    return redirect_to [:my, :tracks] if user_signed_in?

    @tracks = Track.active.order('title ASC')
    @all_exercise_counts = Exercise.where(track_id: @tracks, active: true).group(:track_id).count
    @all_user_tracks_counts = UserTrack.where(track_id: @tracks).group(:track_id).count
  end

  def show
    @track = Track.find(params[:id])
    return redirect_to [:my, @track] if user_signed_in?

    @mentors = @track.active_mentors.reorder(SQLSnippets.random).limit(6)
    @active_maintainers = @track.maintainers.visible.active.order('alumnus DESC', SQLSnippets.random).limit(6)
    @exercises = @track.exercises.active.reorder(SQLSnippets.random).limit(6)
    @testimonial = @track.testimonials.order(SQLSnippets.random).first
    @testimonial = Testimonial.generic.order(SQLSnippets.random).first unless @testimonial

    return redirect_to @track, :status => :moved_permanently if request.path != track_path(@track)
  end

  def join
    @track = Track.find(params[:id])
    return redirect_to [:my, @track] if user_signed_in?

    session[:user_join_track_id] = @track.id
    redirect_to new_user_registration_path
  end

  def maintainers
    @track = Track.find(params[:id])
    @maintainers = @track.maintainers
  end

  def mentors
    @track = Track.find(params[:id])
    @mentors = @track.active_mentors
  end
end
