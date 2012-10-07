require 'factory_girl'

FactoryGirl.define do
  factory :invitation do
    association(:user)
    invitee { FactoryGirl.build(:user) }
  end
end
