require "application_system_test_case"

class SolutionIgnoreRequireActionTest < ApplicationSystemTestCase
  test "ignores require action" do
    @mentor = create(:mentor)
    @track = create(:track, title: "Ruby")
    create :track_mentorship, user: @mentor, track: @track

    @solution = create :solution, exercise: create(:exercise, track: @track), mentoring_requested_at: Time.current
    @iteration = create :iteration, solution: @solution

    solution_mentorship = create :solution_mentorship, solution: @solution, user: @mentor, requires_action_since: Time.current

    assert solution_mentorship.reload.requires_action?

    sign_in!(@mentor)
    visit mentor_solution_path(@solution)

    within ".tools-bar .notification" do
      click_on "No action is required"
    end

    assert_selector "body.namespace-mentor.controller-dashboard.action-your_solutions"
    refute solution_mentorship.reload.requires_action?
  end
end
