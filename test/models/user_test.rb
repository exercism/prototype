require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "self.mentors" do
    user = create :user
    assert_equal [], User.mentors

    create :mentor_profile, user: user
    assert_equal [user], User.mentors
  end

  test "self.active_mentors" do
    track = create :track
    exercise = create :exercise, track: track
    user1 = create :mentor
    user2 = create :mentor
    user3 = create :mentor

    assert_equal [], User.active_mentors

    create :track_mentorship, track: track
    assert_equal [], User.active_mentors

    create :solution_mentorship, user: user1, solution: create(:solution, exercise: exercise)
    assert_equal [user1], User.active_mentors

    create :solution_mentorship, user: user2, created_at: Time.current - 25.days, solution: create(:solution, exercise: exercise)
    assert_equal [user1, user2], User.active_mentors

    create :solution_mentorship, user: user2, created_at: Time.current - 25.days, solution: create(:solution, exercise: exercise)
    assert_equal [user1, user2], User.active_mentors

    create :solution_mentorship, user: user3, created_at: Time.current - 32.days, solution: create(:solution, exercise: exercise)
    assert_equal [user1, user2], User.active_mentors
  end

  test "unlocking track" do
    user = create :user
    track = create :track
    refute user.joined_track?(track)

    create :user_track, user: user, track: track
    assert user.joined_track?(track)
  end

  test "previously joined track" do
    user = create(:user)
    previously_joined = create(:track)
    currently_joined = create(:track)
    create(:user_track,
           user: user,
           track: previously_joined,
           paused_at: Date.new(2016, 12, 25))
    create(:user_track, track: currently_joined, user: user, paused_at: nil)

    assert user.previously_joined_track?(previously_joined)
    refute user.previously_joined_track?(currently_joined)
  end

  test "record cannot be saved without a handle" do
    user = build :user, handle: nil
    refute user.valid?
    assert user.errors.keys.include?(:handle)
  end

  test "record can be updated without handle blowing up" do
    user = create :user, handle: "foobar"
    user.name = "Foobar!"
    user.save!
  end

  test "handle must be unique across user_tracks" do
    handle = SecureRandom.uuid
    create :user_track, handle: handle
    user = build :user, handle: handle
    refute user.valid?
    assert user.errors.keys.include?(:handle)
  end

  test "handle must be unique across users" do
    handle = SecureRandom.uuid
    create :user, handle: handle
    u = build :user, handle: handle
    refute u.valid?
    assert u.errors.keys.include?(:handle)
  end

  test "may_view_solution? for random user" do
    solution = create :solution, published_at: nil
    user = create :user
    refute user.may_view_solution?(solution)
  end

  test "may_view_solution? for solution_user" do
    solution = create :solution
    assert solution.user.may_view_solution?(solution)
  end

  test "may_view_solution? for published solution" do
    solution = create :solution, published_at: DateTime.now - 1.week
    user = create :user
    assert user.may_view_solution?(solution)
  end

  test "may_view_solution? for mentor" do
    solution = create :solution, published_at: DateTime.now - 1.week
    user = create :user
    create :track_mentorship, track: solution.exercise.track, user: user
    assert user.may_view_solution?(solution)
  end

  test "may_view_solution? for team_solution and random user" do
    solution = create :team_solution
    user = create :user
    refute user.may_view_solution?(solution)
  end

  test "may_view_solution? for team_solution and solution_user" do
    solution = create :team_solution
    assert solution.user.may_view_solution?(solution)
  end

  test "may_view_solution? for team_solution and team member" do
    team = create :team
    solution = create :team_solution, team: team

    user = create :user
    create :team_membership, user: user, team: team
    assert user.may_view_solution?(solution)
  end

  test "handle is valid" do
    user = build :user

    assert ((user.handle = "foo") and user.valid?)
    assert ((user.handle = "123foo321") and user.valid?)
    assert ((user.handle = "1-23foo32-1") and user.valid?)

    refute ((user.handle = "") and user.valid?)
    refute ((user.handle = "_23foo32") and user.valid?)
    refute ((user.handle = "foo'bar") and user.valid?)
  end

  test "test_user?" do
    user = build :user
    refute user.test_user?

    user.email = nil
    refute user.test_user?

    user.email = "humpty.dumpty+testexercismuser1@example.com"
    assert user.test_user?

    user.email = "humpty.dumpty+TESTEXERCISMUSER2@example.com"
    assert user.test_user?
  end

  test "may_unlock_user?" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    core_exercise = create :exercise, track: track, core: true
    side_exercise_with_unlock = create :exercise, track: track, core: false, unlocked_by: core_exercise
    side_exercise_without_unlock = create :exercise, track: track, core: false

    refute user.may_unlock_exercise?(core_exercise)
    refute user.may_unlock_exercise?(side_exercise_with_unlock)
    assert user.may_unlock_exercise?(side_exercise_without_unlock)

    user_track.update(independent_mode: true)

    # Reset user to empty caches
    user = User.find(user.id)
    assert user.may_unlock_exercise?(core_exercise)
    assert user.may_unlock_exercise?(side_exercise_with_unlock)
    assert user.may_unlock_exercise?(side_exercise_without_unlock)
  end

  test "avatar_url" do
    attached = create(:user)
    attached.avatar.attach(
      io: File.open("test/fixtures/test.png"),
      filename: "test.png"
    )
    from_github = create(:user, avatar_url: "github.png")
    no_image = create(:user, avatar_url: nil)

    assert_includes attached.avatar_url, "test.png"
    assert_equal "github.png", from_github.avatar_url
    assert_equal User::DEFAULT_AVATAR, no_image.avatar_url
  end

  test "a bad avatar_url doesn't raise an exception" do
    user = create :user
    user.expects(:avatar).raises
    assert_equal User::DEFAULT_AVATAR, user.avatar_url
  end

  test "destroying a user preserves discussions as a mentor and deletes discussions as a learner" do
    user = create(:user)
    mentor_post = create(:discussion_post, user: user)
    solution = create(:solution, user: user)
    iteration = create(:iteration, solution: solution)
    learner_post = create(:discussion_post, iteration: iteration, user: user)
    blog_comment = create(:blog_comment, user: user)
    solution_comment = create(:solution_comment, user: user)
    solution_star = create(:solution_star, user: user)

    user.destroy

    refute DiscussionPost.exists?(learner_post.id)
    refute BlogComment.exists?(blog_comment.id)
    refute SolutionComment.exists?(solution_comment.id)
    refute SolutionStar.exists?(solution_star.id)
    mentor_post.reload
    refute mentor_post.destroyed?
    assert_nil mentor_post.user
  end

  test "onboarded?" do
    not_onboarded_1 = create :user, accepted_terms_at: nil, accepted_privacy_policy_at: nil
    not_onboarded_2 = create :user, accepted_terms_at: DateTime.now - 1.day, accepted_privacy_policy_at: nil
    not_onboarded_3 = create :user, accepted_terms_at: nil, accepted_privacy_policy_at: DateTime.now - 1.day
    onboarded = create :user, accepted_terms_at: DateTime.now - 1.day, accepted_privacy_policy_at: DateTime.now - 1.day

    assert onboarded.onboarded?
    refute not_onboarded_1.onboarded?
    refute not_onboarded_2.onboarded?
    refute not_onboarded_3.onboarded?
  end

  test "validates that avatar is correct format" do
    user = create(:user)
    user.avatar.attach(
      io: File.open("test/fixtures/test.svg"),
      filename: "test.svg"
    )
    other_user = create(:user)
    other_user.avatar.attach(
      io: File.open("test/fixtures/test.png"),
      filename: "test.png"
    )

    refute user.valid?
    assert other_user.valid?
  end

  test "has_active_lock_for_solution?" do
    user = create :user
    solution = create :solution
    refute user.has_active_lock_for_solution?(solution)

    lock = create :solution_lock, user: user, solution: solution, locked_until: Time.current - 1.second
    refute user.has_active_lock_for_solution?(solution)

    lock.update(locked_until: Time.current + 1.minute)
    assert user.has_active_lock_for_solution?(solution)
  end

  test "auth_token" do
    user = create :user
    t1 = create :auth_token, user: user, active: false
    t2 = create :auth_token, user: user, active: true
    t3 = create :auth_token, user: user, active: false

    assert_equal t2.token, user.auth_token
  end

  test "create_auth_token!" do
    user = create :user

    user.create_auth_token!
    token1 = user.auth_tokens.first

    assert_equal 1, user.auth_tokens.size
    assert token1.active?

    user.create_auth_token!
    token1.reload
    token2 = user.auth_tokens.last

    assert_equal 2, user.auth_tokens.size
    refute token1.active?
    assert token2.active?
  end

  test "num_rated_mentored_solutions" do
    user = create :user
    create :solution_mentorship, user: user
    create :solution_mentorship, user: user, rating: 2
    create :solution_mentorship, user: user, rating: 3

    assert_equal 2, user.num_rated_mentored_solutions
  end

  test "User#system_user" do
    other_user = create :user, id: 5
    system_user = create :user, id: User::SYSTEM_USER_ID

    assert_equal system_user, User.system_user
  end

  test "starred_solution?" do
    user = create :user
    solution = create :solution

    refute user.starred_solution?(solution)

    create :solution_star, user: user, solution: solution
    assert user.reload.starred_solution?(solution)
  end

  test "is_mentor?" do
    user = create :user
    refute user.is_mentor?

    create :mentor_profile, user: user
    assert user.is_mentor?
  end

  test "mentor_rating" do
    user = create :user
    assert_equal 0, user.mentor_rating

    create :mentor_profile, user: user, average_rating: 3.2
    assert_equal 3.2, user.reload.mentor_rating
  end

  test "num_solutions_mentored" do
    user = create :user
    assert_equal 0, user.num_solutions_mentored

    create :mentor_profile, user: user, num_solutions_mentored: 15
    assert_equal 15, user.reload.num_solutions_mentored
  end
end
