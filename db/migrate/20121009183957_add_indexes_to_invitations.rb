class AddIndexesToInvitations < ActiveRecord::Migration
  def change
    add_index :invitations, :user_id
    add_index :invitations, :invitee_id
  end
end
