class AddTriagedAsToSolutions < ActiveRecord::Migration[5.2]
  def change
    add_column :solutions, :triaged_as, :string, null: true
  end
end
