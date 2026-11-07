class CreateRiders < ActiveRecord::Migration[8.1]
  def change
    create_table :riders do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :nickname
      t.boolean :female, null: false, default: false
      t.string :nation
      t.date :birthday
      t.string :email, null: false
      t.string :organization
      t.text :info
      t.references :user, null: true, foreign_key: true, index: { unique: true }

      t.timestamps
    end
    add_index :riders, :email, unique: true
  end
end
