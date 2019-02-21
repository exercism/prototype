class RecalculateMentorStatsJob < ApplicationJob
  def perform(user)
    return unless user.mentor_profile
    user.mentor_profile.recalculate_stats!
  end
end
