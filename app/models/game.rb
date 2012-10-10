class Game < ActiveRecord::Base
  include AASM

  belongs_to :owner, class_name: "User"

  validates_presence_of :owner, :start_time

  before_validation :default_start_time

  scope :pending, where(state: 'pending')
  scope :in_progress, where(state: 'in_progress')
  scope :complete, where(state: 'complete')

  scope :owned_by, lambda { |user|
    where(owner_id: user.id)
  }

  attr_accessible :owner_id, :owner

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

protected
  def default_start_time
    self.start_time = Time.zone.now if self.start_time.blank?
  end
end
