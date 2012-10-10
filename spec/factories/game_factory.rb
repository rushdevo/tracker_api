require 'factory_girl'

FactoryGirl.define do
  factory :game do
    owner { |a| a.association(:user) }
  end
end
