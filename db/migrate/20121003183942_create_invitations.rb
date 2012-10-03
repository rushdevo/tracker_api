class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id
      t.integer :invitee_id
      t.string :email_or_login
      t.timestamps
    end
  end
end
