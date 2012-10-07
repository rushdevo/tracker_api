require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@rushdevo.com" }
    first_name "Some"
    last_name "One"
    password "P@ssw0rd"
    password_confirmation "P@ssw0rd"
  end
end
