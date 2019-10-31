class CreateExerciseFixtures < ActiveRecord::Migration[6.0]
  def change
    create_table :exercise_fixtures do |t|
      t.bigint :exercise_id, null: false
      t.bigint :comments_by_id, null: false

      t.text :representation, null: false
      t.string :representation_hash, null: false

      t.string :status, null: false
      t.text :comments_markdown, null: false

      t.timestamps

      t.index [:exercise_id, :representation_hash], unique: true
    end
  end
end
