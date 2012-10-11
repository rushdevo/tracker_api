require 'factory_girl'

FactoryGirl.define do
  factory :user_game do
    association(:user)
    association(:game)
  end
end
