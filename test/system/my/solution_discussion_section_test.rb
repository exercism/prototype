require 'application_system_test_case'

class My::SolutionDiscussionSectionTest < ApplicationSystemTestCase
  test "mentored mode / mentored solution" do
    Git::ExercismRepo.stubs(current_head: "dummy-sha1")

    user = create(:user,
                  accepted_terms_at: Date.new(2016, 12, 25),
                  accepted_privacy_policy_at: Date.new(2016, 12, 25))
    solution = create(:solution, user: user, track_in_independent_mode: false, independent_mode: false)
    create :iteration, solution: solution
    create(:user_track, track: solution.track, user: user)

    sign_in!(user)
    visit my_solution_path(solution)

    assert_selector ".discussion h3", text: "Mentor Discussion"
  end

  test "independent mode / mentored solution" do
    Git::ExercismRepo.stubs(current_head: "dummy-sha1")

    user = create(:user,
                  accepted_terms_at: Date.new(2016, 12, 25),
                  accepted_privacy_policy_at: Date.new(2016, 12, 25))
    solution = create(:solution, user: user, track_in_independent_mode: true, independent_mode: false)
    create :iteration, solution: solution
    create(:user_track, track: solution.track, user: user)

    sign_in!(user)
    visit my_solution_path(solution)

    assert_selector ".discussion h3", text: "Mentor Discussion"
  end

  test "mentored mode / independent solution" do
    Git::ExercismRepo.stubs(current_head: "dummy-sha1")

    user = create(:user,
                  accepted_terms_at: Date.new(2016, 12, 25),
                  accepted_privacy_policy_at: Date.new(2016, 12, 25))
    solution = create(:solution, user: user, track_in_independent_mode: false, independent_mode: true)
    create :iteration, solution: solution
    create(:user_track, track: solution.track, user: user)

    sign_in!(user)
    visit my_solution_path(solution)

    assert_selector ".completed-section .next-option strong", text: "Request mentor feedback."
    refute_selector ".discussion"
  end

  test "independent mode / independent solution" do
    Git::ExercismRepo.stubs(current_head: "dummy-sha1")

    user = create(:user,
                  accepted_terms_at: Date.new(2016, 12, 25),
                  accepted_privacy_policy_at: Date.new(2016, 12, 25))
    solution = create(:solution, user: user, track_in_independent_mode: true, independent_mode: true)
    create :iteration, solution: solution
    create(:user_track, track: solution.track, user: user)

    sign_in!(user)
    visit my_solution_path(solution)

    assert_selector ".completed-section .next-option strong", text: "Request mentor feedback."
    refute_selector ".discussion"
  end
end

