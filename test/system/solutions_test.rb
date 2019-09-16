require "application_system_test_case"

class SolutionsTest < ApplicationSystemTestCase
  test "shows test suite" do
    user = create(:user, :onboarded)
    track = create(:track)
    create(:user_track, track: track, user: user)
    exercise = create(:exercise, track: track)
    solution = create(:solution,
                      exercise: exercise,
                      user: user,
                      git_sha: Git::ExercismRepo.current_head(track.repo_url))
    iteration = create(:iteration, solution: solution)

    sign_in!(user)
    visit my_solution_path(solution)

    find(:css, ".tab", text: "Test suite").click
    assert_text "This is the test suite"
  end

  test "index test suite" do
    user = create(:user, :onboarded)
    solution = create(:solution, published_at: Time.now)

    sign_in!(user)
    visit track_exercise_solutions_path(solution.track, solution.exercise)
  end

  test "can star a solution" do
    user = create(:user, :onboarded)
    solution = create(:solution, published_at: Time.now)

    sign_in!(user)
    visit solution_path(solution)

    assert_equal 0, solution.stars.count

    click_on "Star this solution"
    sleep(0.1)

    solution.reload
    assert_equal 1, solution.stars.count
  end

  test "can unstar a solution" do
    user = create(:user, :onboarded)
    solution = create(:solution, published_at: Time.now)
    star = create(:solution_star, user: user, solution: solution)

    sign_in!(user)
    visit solution_path(solution)

    assert_equal 1, solution.stars.count

    click_on "Starred solution"
    sleep(0.1)

    solution.reload
    assert_equal 0, solution.stars.count
  end

  test "shows vertical split for guest" do
    solution = create(:solution, published_at: Date.new(2016, 12, 25))
    iteration = create(:iteration, solution: solution)

    visit solution_path(solution)

    assert_css ".widget-panels.widget-panels--vertical-split"
  end
end
