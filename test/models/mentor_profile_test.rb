require 'test_helper'

class MentorProfileTest < ActiveSupport::TestCase

  test "recalculate_stats! - num_solutions_mentored" do
    user = create :mentor
    mentor_profile = user.mentor_profile
    assert_equal 0, user.mentor_profile.num_solutions_mentored

    # Don't count uncompleted
    create :solution_mentorship, user: user, rating: nil, solution: create(:solution, completed_at: nil)
    mentor_profile.recalculate_stats!
    assert_equal 0, mentor_profile.num_solutions_mentored

    # Do count nil ratings (not mentors fault if they're not rated)
    create :solution_mentorship, user: user, rating: nil, solution: create(:solution, completed_at: Time.current)
    mentor_profile.recalculate_stats!
    assert_equal 1, mentor_profile.num_solutions_mentored

    # Don't count 3 and below
    create :solution_mentorship, user: user, rating: 1, solution: create(:solution, completed_at: Time.current)
    create :solution_mentorship, user: user, rating: 2, solution: create(:solution, completed_at: Time.current)
    create :solution_mentorship, user: user, rating: 3, solution: create(:solution, completed_at: Time.current)
    mentor_profile.recalculate_stats!
    assert_equal 1, mentor_profile.num_solutions_mentored

    # Do count 4 and 5
    create :solution_mentorship, user: user, rating: 4, solution: create(:solution, completed_at: Time.current)
    create :solution_mentorship, user: user, rating: 5, solution: create(:solution, completed_at: Time.current)
    mentor_profile.recalculate_stats!
    assert_equal 3, mentor_profile.num_solutions_mentored
  end

  test "trimmed average_rating when 5% is under 0.5" do
    user = create :mentor
    mentor_profile = user.mentor_profile
    assert_nil user.mentor_profile.average_rating

    create :solution_mentorship, user: user, rating: 2
    create :solution_mentorship, user: user, rating: 5
    create :solution_mentorship, user: user, rating: 4
    create :solution_mentorship, user: user, rating: nil

    mentor_profile.recalculate_stats!
    assert_equal 3.67, mentor_profile.average_rating
  end

  test "trimmed average_rating with 20 solution memberships" do
    user = create :mentor
    assert_nil user.mentor_profile.average_rating

    2.times do
      create :solution_mentorship, user: user, rating: 1
    end

    5.times do
      create :solution_mentorship, user: user, rating: 2
    end

    create :solution_mentorship, user: user, rating: 3

    5.times do
      create :solution_mentorship, user: user, rating: 4
    end

    7.times do
      create :solution_mentorship, user: user, rating: 5
    end

    create :solution_mentorship, user: user, rating: nil

    user.mentor_profile.recalculate_stats!
    assert_equal 3.63, user.mentor_profile.average_rating
  end

  test "trimmed mentor rating when no ratings are present" do
    user = create :mentor
    assert_nil user.mentor_profile.average_rating

    user.mentor_profile.recalculate_stats!
    assert_equal 0.0, user.mentor_profile.average_rating
  end
end
