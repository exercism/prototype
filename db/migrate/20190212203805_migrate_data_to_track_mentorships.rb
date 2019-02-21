class MigrateDataToTrackMentorships < ActiveRecord::Migration[5.2]
  def change
    rename_table :mentors, :legacy_mentors

    LegacyMentor.find_each do |mtp|
      user = User.find_by_handle(mtp.github_username)
      track_mentorship = TrackMentorship.where(user: user, track_id: mtp.track_id).first
      if track_mentorship
        track_mentorship.update!(
          link_text: mtp.link_txt,
          link_url: mtp.link_url,
          bio: mtp.bio
        )
      end
    end
  end
end
