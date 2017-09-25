FactoryGirl.define do
  factory :comment do
    body "Рандомный коммент"
    user_name "Дядя Жора"

    assosiation :event

    factory :comment_with_author do
      assosiation :user
    end
  end
end
