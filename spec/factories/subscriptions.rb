FactoryGirl.define do
  factory :subscription do
    user_name { "Подписчег №#{rand(123)}" }
    sequence(:user_email) { |n| "subscriber#{n}@example.com" }
    confirmed true
    sequence(:confirm_token) { |n| "token#{n}" }

    association :event

    factory :subscription_with_user do
      association :user
    end
  end
end