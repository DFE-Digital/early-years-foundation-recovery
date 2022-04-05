FactoryBot.define do
  factory :user do
    email { Faker::Internet.safe_email }
    password { 'StrongPassword123' }

    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end

    trait :registered do
      confirmed
      registration_complete { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end
  end
end
