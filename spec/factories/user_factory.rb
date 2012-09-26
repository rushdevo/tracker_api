require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@rushdevo.com" }
    password "P@ssw0rd"
    password_confirmation "P@ssw0rd"
  end
end
