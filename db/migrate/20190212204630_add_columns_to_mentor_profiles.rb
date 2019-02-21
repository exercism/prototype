class AddColumnsToMentorProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :mentor_profiles, :average_rating, :decimal, precision: 3, scale: 2

    MentorProfile.all.each do |mp|
      mp.recalculate_average_rating!
    end
  end
end
