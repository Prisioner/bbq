FactoryBot.define do
  factory :subscription do
    user_name { "Подписчег №#{rand(123)}" }
    sequence(:user_email) { |n| "subscriber#{n}@example.com" }
    confirmed true
    sequence(:confirm_token) { |n| "token#{n}" }
    user nil

    association :event
  end

  factory :subscription_with_user, class: 'Subscription' do
    user_name nil
    user_email nil
    confirmed true

    association :event
    association :user
  end

  factory :invalid_subscription, class: 'Subscription' do
    user_name nil
    user_email nil
  end
end
