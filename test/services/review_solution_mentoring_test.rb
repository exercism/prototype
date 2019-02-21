require 'test_helper'

class ReviewSolutionMentoringTest < ActiveSupport::TestCase
  test "reviews in valid case" do
    solution_mentorship = create :solution_mentorship
    solution = solution_mentorship.solution
    mentor = solution_mentorship.user
    um = create :mentor

    rating = 2
    feedback = "The foo was not enough bar"

    ReviewSolutionMentoring.(
      solution, mentor, rating, feedback
    )

    solution_mentorship.reload
    assert_equal solution_mentorship.rating, rating
    assert_equal solution_mentorship.feedback, feedback
    refute solution_mentorship.show_feedback_to_mentor
  end

  test "recalculates_average_rating" do
    mentor = create :mentor
    solution_mentorship = create :solution_mentorship, user: mentor
    create :solution_mentorship, user: mentor, rating: 5

    RecalculateMentorStatsJob.expects(:perform_later).with(mentor)
    ReviewSolutionMentoring.(solution_mentorship.solution, mentor, 3, "")
  end
end
