class ReviewSolutionMentoring
  include Mandate

  initialize_with :solution, :mentor, :rating, :feedback

  def call
    solution_mentorship.update!(
      rating: rating,
      feedback: feedback,
      show_feedback_to_mentor: false
    )
    RecalculateMentorStatsJob.perform_later(mentor)
  end

  def solution_mentorship
    @solution_mentorship ||=
      solution.mentorships.where(user_id: mentor).first!
  end
end

