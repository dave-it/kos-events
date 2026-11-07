class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :location
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.boolean :published, null: false, default: false

      t.timestamps
    end
    add_index :events, :starts_at
    add_index :events, :published
  end
end
