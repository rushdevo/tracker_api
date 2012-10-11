class UserGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  validates_presence_of :user, :game

  attr_accessible :user_id, :user, :game_id, :game
end
