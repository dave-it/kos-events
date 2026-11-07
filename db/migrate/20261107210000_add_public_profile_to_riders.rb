class AddPublicProfileToRiders < ActiveRecord::Migration[8.1]
  def change
    add_column :riders, :public_profile, :boolean, null: false, default: false
    add_column :riders, :public_profile_consented_at, :datetime
    add_index :riders, :public_profile
  end
end
