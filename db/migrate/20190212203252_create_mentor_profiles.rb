class CreateMentorProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :mentor_profiles do |t|
      t.bigint :user_id, null: false
      t.text :bio, null: true

      t.timestamps
    end

    User.where(is_mentor: true).each do |user|
      MentorProfile.create!(
        user: user,
        bio: user.profile.try(:bio)
      )
    end
  end
end
