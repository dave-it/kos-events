class AddLocaleToRiders < ActiveRecord::Migration[8.1]
  def change
    add_column :riders, :locale, :string, null: false, default: "de"
  end
end
