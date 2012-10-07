class AddTokenToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :token, :string, limit: 20
    add_index :invitations, :token
  end
end
