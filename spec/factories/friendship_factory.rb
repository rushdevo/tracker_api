require 'factory_girl'

FactoryGirl.define do
  factory :friendship do
    association(:user)
    friend { |a| a.association(:user) }
  end
end
