require 'test_helper'

class Mentor::SolutionsControllerTest < ActionDispatch::IntegrationTest

  test "approve calls service" do
    mentor = create :user
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise

    sign_in!(mentor)

    ApproveSolution.expects(:call).with(solution, mentor)
    patch approve_mentor_solution_url(solution), as: :js
    assert_response :success
  end

  test "show clears notifications" do
    mentor = create :user
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise
    iteration = create :iteration, solution: solution

    sign_in!(mentor)

    ClearsNotifications.expects(:clear!).with(mentor, solution)
    ClearsNotifications.expects(:clear!).with(mentor, iteration)

    get mentor_solution_url(solution)
    assert_response :success
  end

end
