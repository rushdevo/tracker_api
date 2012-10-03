require 'factory_girl'

FactoryGirl.define do
  factory :invitation do
    association(:user)
    invitee { FactoryGirl.build(:user) }
    email_or_login { invitee.login }
  end
end
