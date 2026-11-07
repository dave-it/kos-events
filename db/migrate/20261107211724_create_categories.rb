class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :female, null: false, default: false
      t.boolean :juniors, null: false, default: false

      t.timestamps
    end
    add_index :categories, [ :event_id, :name ], unique: true
  end
end
