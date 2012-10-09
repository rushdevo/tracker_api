class AddInvitationIdToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :invitation_id, :integer
    add_index :friendships, :invitation_id
  end
end
