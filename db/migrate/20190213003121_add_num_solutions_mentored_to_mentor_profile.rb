class AddNumSolutionsMentoredToMentorProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :mentor_profiles, :num_solutions_mentored, :integer, default: 0, null: false

    MentorProfile.all.each do |mp|
      mp.recalculate_stats!
    end
  end
end
