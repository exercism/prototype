require 'test_helper'

class Mentor::DiscussionPostsControllerTest < ActionDispatch::IntegrationTest
  test "approve calls service" do
    mentor = create :mentor
    track = create :track
    exercise = create :exercise, track: track
    create :track_mentorship, user: mentor, track: track
    solution = create :solution, exercise: exercise
    iteration = create :iteration, solution: solution
    content = "The big fat foobar"

    sign_in!(mentor)

    CreatesMentorDiscussionPost.expects(:create!).with(iteration, mentor, content).returns(create(:discussion_post))
    ApproveSolution.expects(:call).with(solution, mentor)
    post mentor_discussion_posts_url(iteration_id: iteration,
                                     discussion_post: {content: content},
                                     button: "approved"
                                    ), as: :js
    assert_response :success
  end
end
