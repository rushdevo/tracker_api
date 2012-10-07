class ChangeInvitationsEmailOrLoginToJustEmail < ActiveRecord::Migration
  def up
    rename_column :invitations, :email_or_login, :email
  end

  def down
    rename_column :invitations, :email, :email_or_login
  end
end
