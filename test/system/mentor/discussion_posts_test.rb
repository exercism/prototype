require "application_system_test_case"

class Mentor::DiscussionPostsTest < ApplicationSystemTestCase
  setup do
    @mentor = create(:mentor,
                  accepted_terms_at: Date.new(2016, 12, 25),
                  accepted_privacy_policy_at: Date.new(2016, 12, 25))

    @track = create :track
    @solution = create :solution, exercise: create(:exercise, track: @track), mentoring_requested_at: Time.current
    @iteration = create :iteration, solution: @solution
    create :track_mentorship, user: @mentor, track: @track
    create :solution_mentorship, user: @mentor, solution: @solution

    sign_in!(@mentor)
  end

  test "user posts a discussion post" do
    visit mentor_solution_path(@solution)

    text = "Some sample content"
    find(".new-editable-text textarea").set(text)
    click_on "Comment"

    assert_text text
    discussion_post = DiscussionPost.last
    assert_equal text, discussion_post.content
    assert_equal @mentor, discussion_post.user
    assert_equal @iteration, discussion_post.iteration
  end

  test "user edits a discussion post" do
    discussion_post = create(:discussion_post,
                             content: "Hello!",
                             html: "<p>Hello!</p>",
                             user: @mentor,
                             iteration: @iteration)
    visit mentor_solution_path(@solution)
    click_on "Edit"
    within(".editable-text.editing") { fill_in("discussion_post_content", with: "Hey!") }
    click_on "Save changes"

    assert_text "Hey!"
    # I've commented this line out in the HAML for now
    # assert_text "(edited less than a minute ago)"
    discussion_post.reload
    assert_equal "Hello!", discussion_post.previous_content
  end

  test "user deletes a discussion post" do
    discussion_post = create(:discussion_post,
                             content: "Hello!",
                             html: "<p>Hello!</p>",
                             user: @mentor,
                             iteration: @iteration)

    visit mentor_solution_path(@solution)
    accept_confirm do
      click_on "Delete"
    end

    assert_text "This message has been deleted"
  end

  test "comment button clears preview tab" do

    visit mentor_solution_path(@solution)

    assert_selector ".comment-button"
    assert_selector ".markdown"
    refute_selector ".preview"

    find(".new-editable-text textarea").set("An example mentor comment to test the comment button!")
    find(".preview-tab").click
    within(".preview-area") { assert_text "An example mentor comment to test the comment button!" }
    click_on "Comment"
    within(".preview-area") { assert_text "", { exact: true } }
  end

  test "localstorage saves comment draft" do
    visit mentor_solution_path(@solution)

    assert_selector ".comment-button"
    assert_selector ".markdown"
    refute_selector ".preview"

    assert_equal "", find(".new-editable-text textarea").value
    find(".new-editable-text textarea").set("An example mentor comment to test the comment button!")

    visit mentor_solution_path(@solution)

    assert_equal "An example mentor comment to test the comment button!", find(".new-editable-text textarea").value
    find(".new-editable-text textarea").set("")

    visit mentor_solution_path(@solution)

    assert_equal "", find(".new-editable-text textarea").value
  end
end
