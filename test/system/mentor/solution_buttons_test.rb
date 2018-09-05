require "application_system_test_case"

class SolutionButtonsTest < ApplicationSystemTestCase
  setup do
    @mentor = create(:user)
    @track = create(:track, title: "Ruby")
    create :track_mentorship, user: @mentor, track: @track

    @solution = create :solution, exercise: create(:exercise, track: @track)
    @iteration = create :iteration, solution: @solution

    sign_in!(@mentor)
  end

  test "shows buttons if not approved" do
    create :solution_mentorship, solution: @solution, user: @mentor

    visit mentor_solution_path(@solution)

    assert_selector ".leave-button"
    assert_selector ".approve-button"
    assert_selector ".comment-button"
  end

  test "does not show buttons if approved" do
    create :solution_mentorship, solution: @solution, user: @mentor
    @solution.update(approved_by: create(:user))

    visit mentor_solution_path(@solution)

    refute_selector ".leave-button"
    refute_selector ".approve-button"
    assert_selector ".comment-button"
  end

  test "comment button clears preview tab" do
    create :solution_mentorship, solution: @solution, user: @mentor

    visit mentor_solution_path(@solution)

    assert_selector ".comment-button"
    assert_selector ".markdown"
    refute_selector ".preview"
    find(".new-discussion-post-form textarea").set("An example mentor comment to test the comment button!")
    find(".preview-tab").click
    within(".preview-area") { assert_text "An example mentor comment to test the comment button!" }
    click_on "Comment"
    within(".preview-area") { assert_text "", { exact: true } }
  end

  test "can report a solution" do
    create :solution_mentorship, solution: @solution, user: @mentor

    visit mentor_solution_path(@solution)

    assert_selector ".report-button", text: "Report"

    click_on "Report"

    assert_selector "#modal.mentor-solution-report textarea"
    report_text = "My example mentor report " + SecureRandom.uuid
    fill_in "report_text", with: report_text

    click_on "Send"

    assert_selector "#modal.mentor-solution-report-send"
    assert CoCReport.where(user: @mentor, solution_uuid: @solution.uuid, report_text: report_text).exists?

    click_on "Continue"

    refute_selector "#modal"
  end
end
