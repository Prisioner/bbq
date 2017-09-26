FactoryGirl.define do
  factory :photo do
    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'photos', 'photo1.jpg'), 'image/jpeg') }

    association :event
    association :user
  end

  factory :invalid_photo, class: 'Photo' do
    photo nil
  end
end
