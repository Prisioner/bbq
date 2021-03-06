FactoryBot.define do
  factory :event do
    title "Супервечеринка"
    description "Вечеринка у Децла дома"
    address "дом Децла"
    datetime DateTime.parse('31.12.2017 18:00')
    pincode nil

    association :user
  end

  factory :invalid_event, class: 'Event' do
    title nil
    address nil
    datetime nil
  end
end
