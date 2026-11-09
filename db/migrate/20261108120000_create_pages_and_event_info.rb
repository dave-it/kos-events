class CreatePagesAndEventInfo < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :slug, null: false
      t.string :title_de, null: false
      t.string :title_en, null: false
      t.text :body_de, null: false, default: ""
      t.text :body_en, null: false, default: ""
      t.string :nav, null: false, default: "none" # header, footer, none
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true
      t.timestamps
    end
    add_index :pages, :slug, unique: true

    change_table :events do |t|
      t.text :info_de
      t.text :info_en
      t.string :registration_url
      t.datetime :registration_deadline
    end
  end
end
