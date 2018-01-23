FactoryBot.define do
  factory :user do
    name { "Товарищ #{rand(123)}" }

    sequence(:email) { |n| "user#{n}@example.com" }

    after(:build) { |user| user.password = '12345678' }
  end
end
