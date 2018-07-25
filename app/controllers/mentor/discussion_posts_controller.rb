class Mentor::DiscussionPostsController < MentorController
  def create
    @iteration = Iteration.find(params[:iteration_id])
    @solution = @iteration.solution

    return head 403 unless current_user.mentoring_track?(@solution.exercise.track)
    return head 403 if current_user == @iteration.solution.user

    ApproveSolution.(@solution, current_user) if params['button'] == 'approved'

    @post = CreatesMentorDiscussionPost.create!(@iteration, current_user, params[:discussion_post][:content])
    @user_track = UserTrack.where(user: current_user, track: @iteration.solution.exercise.track).first
  end
end
