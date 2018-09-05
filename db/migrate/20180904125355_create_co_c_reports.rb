class CreateCoCReports < ActiveRecord::Migration[5.2]
  def change
    create_table :co_c_reports do |t|
      t.text :solution_uuid, null: false
      t.bigint :user_id, null: false
      t.text :report_text, null: false

      t.timestamps
    end

    add_foreign_key :co_c_reports, :users
  end
end
