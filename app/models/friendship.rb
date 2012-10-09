class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"
  belongs_to :invitation

  validates_presence_of :user, :friend

  attr_accessible :user_id, :user, :friend_id, :friend

  scope :for_user, lambda { |user|
    where("user_id = ? OR friend_id = ?", user.id, user.id)
  }

  def simple_json
    {
      id: id,
      user: user.try(:simple_json),
      friend: friend.try(:simple_json),
      invitation: invitation.try(:simple_json)
    }
  end

  def can_modify?(auser)
    auser && (auser == user || auser == friend)
  end
end
