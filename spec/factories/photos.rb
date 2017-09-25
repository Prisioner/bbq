FactoryGirl.define do
  factory :photo do
    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'photos', 'photo1.jpg'), 'image/jpeg') }

    association :event
    association :user
  end
end
