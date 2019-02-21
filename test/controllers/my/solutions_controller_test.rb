require 'test_helper'

class SolutionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @mock_exercise = stub(
      instructions: "instructions",
      test_suite: { "test_file" => "test_suite" },
      files: [],
      about_present: false
    )

    @mock_repo = stub(exercise: @mock_exercise)
    @mock_repo = stub(head: "")
    Git::Exercise.stubs(new: @mock_exercise)
    Git::ExercismRepo.stubs(new: @mock_repo)
    Git::ExercismRepo::PAGES.each do |page|
      @mock_repo.stubs("#{page}_present?", false)
    end
  end

  test "404s with invalid solution uuid" do
    sign_in!
    get my_solution_url("1234")
    assert_response :missing
  end

  test "301s with someone else's solution uuid" do
    sign_in!
    solution = create :solution
    get my_solution_url(solution.uuid)
    assert_redirected_to solution_url(solution)
  end

  {
    unlocked: "my-solution-unlocked-page",
    iterating: "my-solution-page",
    completed_unapproved: "my-solution-page",
    completed_approved: "my-solution-page",
  }.each do |status, page|
    test "shows with status #{status}" do
      sign_in!
      solution = send("create_#{status}_solution")
      solution.exercise.track.stubs(repo: @mock_repo)
      create :user_track, user: @current_user, track: solution.exercise.track

      get my_solution_url(solution)
      assert_response :success
      assert_correct_page page
    end
  end
    test "clears notifications" do
      sign_in!
      solution = create :solution, user: @current_user
      iteration = create :iteration, solution: solution
      create :user_track, user: @current_user, track: solution.exercise.track

      ClearNotifications.expects(:call).with(@current_user, solution)
      ClearNotifications.expects(:call).with(@current_user, iteration)

      get my_solution_url(solution)
    end

  test "reflects properly" do
    sign_in!
    track = create :track
    user_track = create :user_track, track: track, user: @current_user

    exercise = create :exercise, core: true, track: track
    solution = create :solution, user: @current_user, exercise: exercise
    iteration = create :iteration, solution: solution
    get my_solution_url(solution)
    assert_response :success

    discussion_post_1 = create :discussion_post, iteration: iteration
    discussion_post_2 = create :discussion_post, iteration: iteration
    discussion_post_3 = create :discussion_post, iteration: iteration
    reflection = "foobar"

    create :solution_mentorship, solution: solution, user: discussion_post_1.user
    create :solution_mentorship, solution: solution, user: discussion_post_3.user

    # Create next core exercise for user
    next_exercise = create :exercise, track: exercise.track, position: 2, core: true
    create :solution, user: @current_user, exercise: next_exercise

    patch reflect_my_solution_url(solution), params: {
      reflection: reflection,
      mentor_reviews: {
        discussion_post_1.user_id => { rating: 3, review: "asdasd" },
        discussion_post_3.user_id => { rating: 2, review: "asdaqweqwewqewq" }
      }
    }

    assert_response :success

    solution.reload
    assert_equal solution.reflection, reflection
    assert_equal 2, SolutionMentorship.where.not(rating: nil).count
  end

  test "request_mentoring calls service" do
    Timecop.freeze do
      sign_in!
      solution = create :solution, user: @current_user

      RequestMentoringOnSolution.expects(:call).with(solution)

      patch request_mentoring_my_solution_url(solution.uuid)
      assert_redirected_to my_solution_url(solution.uuid)
    end
  end

  test "reflects without next core exercise" do
    skip
  end

  def create_unlocked_solution
    create :solution, user: @current_user
  end

  def create_iterating_solution
    solution = create :solution, user: @current_user
    iteration = create :iteration, solution: solution
    solution
  end

  def create_completed_unapproved_solution
    solution = create :solution, user: @current_user, completed_at: Date.yesterday
    iteration = create :iteration, solution: solution
    solution
  end

  def create_completed_approved_solution
    solution = create :solution, user: @current_user, completed_at: Date.yesterday, approved_by: create(:user)
    iteration = create :iteration, solution: solution
    solution
  end
end
