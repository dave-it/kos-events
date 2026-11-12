class AddRoleToInvitations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :invitations, :rider_id, true
    add_column :invitations, :role, :string, null: false, default: "rider"
    add_column :invitations, :locale, :string, null: false, default: "de"
  end
end
