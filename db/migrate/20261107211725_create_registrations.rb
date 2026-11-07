class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :rider, null: false, foreign_key: true
      t.integer :start_number
      t.datetime :waiver_signed_at
      t.datetime :checked_in_at

      t.timestamps
    end
    add_index :registrations, [ :event_id, :rider_id ], unique: true
    add_index :registrations, [ :event_id, :start_number ], unique: true
  end
end
