FactoryGirl.define do
  factory :comment do
    body "Рандомный коммент"
    user_name "Дядя Жора"

    association :event

    factory :comment_with_author do
      association :user
    end
  end
end
