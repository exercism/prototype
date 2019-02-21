class AddIndexToMentorProfiles < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :mentor_profiles, :users
  end
end
