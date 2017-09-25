FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Событие №#{n}" }
    description "Вечеринка у Децла дома"
    address "дом Децла"
    datetime DateTime.parse('31.12.2017 18:00')
    pincode nil

    association :user
  end
end
