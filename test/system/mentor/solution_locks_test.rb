require "application_system_test_case"

class SolutionLocksTest < ApplicationSystemTestCase
  setup do
    @mentor = create(:mentor)
    @track = create(:track, title: "Ruby")
    create :track_mentorship, user: @mentor, track: @track

    @solution = create :solution, exercise: create(:exercise, track: @track), mentoring_requested_at: Time.current
    @iteration = create :iteration, solution: @solution

    sign_in!(@mentor)
  end

  test "shows discussion if the user is mentoring" do
    create :solution_mentorship, solution: @solution, user: @mentor

    visit mentor_solution_path(@solution)

    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"
  end

  test "shows discussion if the user has a lock" do
    create :solution_lock, solution: @solution, user: @mentor, locked_until: Time.current + 1.minute

    visit mentor_solution_path(@solution)

    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"
  end

  test "shows claim-section if no lock" do
    visit mentor_solution_path(@solution)

    assert_selector ".claim-section"
    refute_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution"
    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"
  end

  test "shows claim-section and discussions but no form if no lock but posts" do
    create :discussion_post, iteration: @iteration
    visit mentor_solution_path(@solution)

    assert_selector ".claim-section"
    assert_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution"
    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"
  end

  test "check force works" do
    create :solution_lock, solution: @solution, user: create(:user), locked_until: Time.current + 1.minute

    visit mentor_solution_path(@solution)

    assert_selector ".claim-section"
    refute_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution"
    assert_selector ".claim-section"
    refute_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution anyway"
    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"
  end

  test "mentor can leave solution without adding a comment" do
    create :system_user

    visit next_solutions_mentor_dashboard_path
    assert page.has_link?(nil, {href: mentor_solution_path(@solution)})

    visit mentor_solution_path(@solution)

    assert_selector ".claim-section"
    refute_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution"
    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"

    click_on "Leave conversation"
    assert page.has_content?("Mentor dashboard")
    assert page.has_no_link?(nil, {href: mentor_solution_path(@solution)})
  end

  test "mentor can leave solution after adding a comment" do
    create :system_user

    visit next_solutions_mentor_dashboard_path
    assert page.has_link?(nil, {href: mentor_solution_path(@solution)})

    visit mentor_solution_path(@solution)

    assert_selector ".claim-section"
    refute_selector ".discussion"
    refute_selector ".new-editable-text"

    click_on "Review this solution"
    assert_selector ".discussion"
    assert_selector ".new-editable-text"
    refute_selector ".claim-section"

    find(".new-editable-text textarea").set("An example mentor comment to test the comment button!")
    click_on "Comment"

    click_on "Leave conversation"
    assert page.has_content?("Mentor dashboard")
    assert page.has_no_link?(nil, {href: mentor_solution_path(@solution)})
  end
end
