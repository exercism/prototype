require 'test_helper'

class RecalculateMentorStatsJobTest < ActiveJob::TestCase
  test "doesn't blow up without mentor profile" do
    user = create :user
    assert_nothing_raised  do
      RecalculateMentorStatsJob.perform_now(user)
    end
  end

  test "calls recalculate_stats!" do
    user = create :mentor
    user.mentor_profile.expects(:recalculate_stats!)
    RecalculateMentorStatsJob.perform_now(user)
  end
end
