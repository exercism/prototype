require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  test "active_mentors" do
    track = create :track
    exercise = create :exercise, track: track
    user1 = create :mentor
    user2 = create :mentor
    user3 = create :mentor

    assert_equal 0, track.num_active_mentors
    assert_equal [], track.active_mentors

    create :track_mentorship, track: track
    assert_equal 0, track.num_active_mentors
    assert_equal [], track.active_mentors

    create :solution_mentorship, user: user1, solution: create(:solution, exercise: exercise)
    assert_equal 1, track.num_active_mentors
    assert_equal [user1], track.active_mentors

    create :solution_mentorship, user: user2, created_at: Time.current - 25.days, solution: create(:solution, exercise: exercise)
    assert_equal 2, track.num_active_mentors
    assert_equal [user1, user2], track.active_mentors

    create :solution_mentorship, user: user2, created_at: Time.current - 25.days, solution: create(:solution, exercise: exercise)
    assert_equal 2, track.num_active_mentors
    assert_equal [user1, user2], track.active_mentors

    create :solution_mentorship, user: user3, created_at: Time.current - 32.days, solution: create(:solution, exercise: exercise)
    assert_equal 2, track.num_active_mentors
    assert_equal [user1, user2], track.active_mentors
  end
end
