require 'test_helper'

class AbandonSolutionMentorshipTest < ActiveSupport::TestCase
  test "works with mentorship when mentor times-out" do
    create :system_user

    mentor = create :mentor, handle: 'freddie'
    solution = create :solution
    iteration = create :iteration, solution: solution
    mentorship = create :solution_mentorship, user: mentor, solution: solution

    AbandonSolutionMentorship.(mentorship, :timed_out)

    [solution, mentorship].each(&:reload)
    assert mentorship.abandoned
    assert_equal 0, solution.num_mentors

    # Check discussion post has been created
    content = {'i18n_message' => 'system_messages.mentor_timed_out', 'handle' => mentor.handle}
    html = ParseMarkdown.("Mentor 'freddie' has been removed from this conversation due to inactivity. This solution has been resubmitted to the queue for a new mentor to review.")

    dp = DiscussionPost.last
    assert_equal User.system_user, dp.user
    assert_equal iteration, dp.iteration
    assert_equal content, JSON.parse(dp.content)
    assert_equal html, dp.html
  end

  test "works with mentorship when mentor leaves conversation" do
    create :system_user

    mentor = create :mentor, handle: 'bobby'
    solution = create :solution
    iteration = create :iteration, solution: solution
    mentorship = create :solution_mentorship, user: mentor, solution: solution

    AbandonSolutionMentorship.(mentorship, :left_conversation)

    [solution, mentorship].each(&:reload)
    assert mentorship.abandoned
    assert_equal 0, solution.num_mentors

    content = {'i18n_message' => 'system_messages.mentor_left_conversation', 'handle' => mentor.handle}
    html = ParseMarkdown.("Mentor 'bobby' has left this conversation. This solution has been resubmitted to the queue for a new mentor to review.")
    dp = DiscussionPost.last
    assert_equal User.system_user, dp.user
    assert_equal iteration, dp.iteration
    assert_equal content, JSON.parse(dp.content)
    assert_equal html, dp.html
  end

  test "works with mentorship for other reason" do
    mentor = create :mentor
    solution = create :solution
    iteration = create :iteration, solution: solution
    mentorship = create :solution_mentorship, user: mentor, solution: solution

    AbandonSolutionMentorship.(mentorship, nil)

    [solution, mentorship].each(&:reload)
    assert mentorship.abandoned
    assert_equal 0, solution.num_mentors

    refute DiscussionPost.where(iteration: iteration).exists?
  end

  test "if the user has already abandoned this is a no-op" do
    mentor = create :mentor
    solution = create :solution
    iteration = create :iteration, solution: solution
    mentorship = create :solution_mentorship, user: mentor, solution: solution, abandoned: true

    AbandonSolutionMentorship.(mentorship, :left_conversation)

    [solution, mentorship].each(&:reload)
    assert mentorship.abandoned
    assert_equal 0, solution.num_mentors
    refute DiscussionPost.where(iteration: iteration).exists?
  end

end
