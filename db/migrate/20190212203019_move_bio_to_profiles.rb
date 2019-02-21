class MoveBioToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :bio, :text, null: true

    Profile.includes(:user).each do |profile|
      profile.update!(bio: profile.user.bio)
    end

    # TODO - Do this manually
    #remove_column :users, :bio
  end
end
