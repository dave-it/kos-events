class PrepareResultsAndImport < ActiveRecord::Migration[8.1]
  def change
    # Herkunfts-IDs aus dem alten kos, damit Importe wiederholbar sind.
    %i[events categories riders registrations].each do |table|
      add_column table, :legacy_id, :integer
      add_index table, :legacy_id, unique: true, where: "legacy_id IS NOT NULL"
    end


    # Ein Fahrer kann in mehreren Kategorien desselben Events starten.
    remove_index :registrations, [ :event_id, :rider_id ]
    add_index :registrations, [ :category_id, :rider_id ], unique: true
    # Startnummern sind pro Kategorie eindeutig (im alten kos trugen Women und Men jeweils eine Nr. 23).
    remove_index :registrations, [ :event_id, :start_number ]
    add_index :registrations, [ :category_id, :start_number ], unique: true, where: "start_number IS NOT NULL"
    add_column :registrations, :trial_number, :integer
    add_column :registrations, :qualification_times, :json, null: false, default: []
    add_column :registrations, :points, :float

    create_table :heats do |t|
      t.references :category, null: false, foreign_key: true
      t.integer :round, null: false, default: 0
      t.integer :number, null: false, default: 1
      t.boolean :lcq, null: false, default: false
      t.boolean :finished, null: false, default: false
      t.integer :legacy_id
      t.timestamps
    end
    add_index :heats, [ :category_id, :round, :number, :lcq ]
    add_index :heats, :legacy_id, unique: true, where: "legacy_id IS NOT NULL"

    create_table :heat_entries do |t|
      t.references :heat, null: false, foreign_key: true
      t.references :registration, null: false, foreign_key: true
      t.integer :place
      t.integer :gate_pick
      t.string :gate_color
      t.integer :legacy_id
      t.timestamps
    end
    add_index :heat_entries, [ :heat_id, :registration_id ], unique: true
    add_index :heat_entries, :legacy_id, unique: true, where: "legacy_id IS NOT NULL"
  end
end
