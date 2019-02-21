require 'test_helper'

class Mentor::SolutionsControllerTest < ActionDispatch::IntegrationTest
  test "show permissions" do
    user = create :user
    solution = create :solution
    create :iteration, solution: solution

    sign_in!(user)

    get mentor_solution_url(solution)
    assert_redirected_to new_mentor_registrations_path

    create :mentor_profile, user: user
    get mentor_solution_url(solution)
    assert_response :success

    solution.update(user: user)
    get mentor_solution_url(solution)
    assert_redirected_to my_solution_path(solution)
  end

  test "approve calls service" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise

    sign_in!(mentor)

    ApproveSolution.expects(:call).with(solution, mentor)
    patch approve_mentor_solution_url(solution), as: :js
    assert_response :success
  end

  test "show sets anonmyous mode correctly" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise
    iteration = create :iteration, solution: solution

    sign_in!(mentor)

    get mentor_solution_url(solution)
    assert_response :success
    refute assigns[:redact_users]

    solution.update(num_mentors: 1)
    get mentor_solution_url(solution)
    assert_response :success
    assert assigns[:redact_users]

    solution.update(num_mentors: 0, approved_by: create(:user))
    get mentor_solution_url(solution)
    assert_response :success
    assert assigns[:redact_users]

    create :solution_mentorship, user: mentor, solution: solution
    get mentor_solution_url(solution)
    assert_response :success
    refute assigns[:redact_users]
  end

  test "show clears notifications" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise
    iteration = create :iteration, solution: solution

    sign_in!(mentor)

    ClearNotifications.expects(:call).with(mentor, solution)
    ClearNotifications.expects(:call).with(mentor, iteration)

    get mentor_solution_url(solution)
    assert_response :success
  end

  test "abandon works without solution mentorship" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise

    sign_in!(mentor)

    AbandonSolutionMentorship.expects(:call).with do |mentorship, message_type|
      assert_nil message_type
      assert mentorship.is_a?(SolutionMentorship)
      assert_equal mentor, mentorship.user
      assert_equal solution, mentorship.solution
    end

    patch abandon_mentor_solution_url(solution), as: :js
    assert SolutionMentorship.where(solution: solution, user: mentor).exists?
    assert_redirected_to mentor_dashboard_path
  end

  test "abandon works with solution mentorship" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise
    mentorship = create :solution_mentorship, solution: solution, user: mentor

    sign_in!(mentor)

    AbandonSolutionMentorship.expects(:call).with(mentorship, :left_conversation)
    patch abandon_mentor_solution_url(solution), as: :js
    assert_redirected_to mentor_dashboard_path
  end

end
