class CreateChat < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_rooms do |t|
      t.string :name_de, null: false
      t.string :name_en, null: false
      t.string :description_de
      t.string :description_en
      # Rollen, die den Kanal sehen (Organisatoren sehen immer alles).
      t.string :audience, array: true, null: false, default: []
      # true: nur Organisatoren dürfen schreiben, die Zielgruppe liest mit.
      t.boolean :organizers_only, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :chat_rooms, :name_de, unique: true

    create_table :chat_messages do |t|
      t.references :chat_room, null: false, foreign_key: true, index: false
      # Nachrichten bleiben erhalten, wenn ein Zugang entzogen wird.
      t.references :user, foreign_key: { on_delete: :nullify }
      t.text :body, null: false
      t.timestamps
    end
    add_index :chat_messages, %i[chat_room_id id]

    create_table :chat_reads do |t|
      t.references :chat_room, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.bigint :last_read_message_id, null: false, default: 0
      t.timestamps
    end
    add_index :chat_reads, %i[chat_room_id user_id], unique: true
  end
end
