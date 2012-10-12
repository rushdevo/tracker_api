class Game < ActiveRecord::Base
  include AASM

  belongs_to :owner, class_name: "User"
  has_many :user_games, dependent: :destroy
  has_many :users, through: :user_games

  validates_presence_of :owner, :start_time

  before_validation :default_start_time
  before_save :make_owner_participate, on: :create

  scope :pending, where(state: 'pending')
  scope :in_progress, where(state: 'in_progress')
  scope :complete, where(state: 'complete')
  scope :incomplete, where("state = ? OR state = ?", 'pending', 'in_progress')

  scope :owned_by, lambda { |user|
    where(owner_id: user.id)
  }

  scope :for_user, lambda { |user|
    joins(:user_games).where('user_games.user_id' => user.id)
  }

  attr_accessible :start_time

  # State Machine
  aasm column: :state do
    state :pending, initial: true
    state :in_progress
    state :complete

    event :start do
      transitions :to => :in_progress, :from => [:pending]
    end

    event :finish do
      transitions :to => :complete, :from => [:pending, :in_progress]
    end
  end

  def joining_user_id=(user_id)
    user = User.find_by_id(user_id)
    user_games.create(game: self, user: user) if user && !users.include?(user)
  end

  def leaving_user_id=(user_id)
    user = User.find_by_id(user_id)
    user_games.where(user_id: user.id).first.try(:destroy) if user
  end

  # Returns true if params can be modified by the given user
  # True if the given user is the owner, or if the params only
  # has keys for joining or leaving the game
  def validate_params_for(user, params)
    user == owner || (params.keys.map(&:to_sym) - [:joining_user_id, :leaving_user_id]).empty?
  end

  def simple_json
    {
      id: id,
      start_time: start_time,
      state: state,
      owner: owner.try(&:simple_json),
      users: users.map(&:simple_json)
    }
  end

protected
  def default_start_time
    self.start_time = Time.zone.now if self.start_time.blank?
  end

  def make_owner_participate
    if owner.present? && !users.include?(owner)
      user_games.build(user: owner, game: self)
    end
  end
end
