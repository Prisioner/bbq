FactoryBot.define do
  factory :comment do
    body "Рандомный коммент"
    user_name "Дядя Жора"

    user nil

    association :event
  end

  factory :comment_with_author, class: 'Comment' do
    body "Рандомный коммент"
    user_name nil

    association :event
    association :user
  end

  factory :invalid_comment, class: 'Comment' do
    body nil
    user_name nil
    user nil

    association :event
  end
end
