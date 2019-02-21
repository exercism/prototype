class RemoveIsMentorColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_mentor
  end
end
