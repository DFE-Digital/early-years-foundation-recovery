FactoryBot.define do
  # registered
  factory :user do
    email { Faker::Internet.safe_email }
    password { 'StrongPassword123' }

    # confirmed
    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end

    # completed
    trait :registered do
      confirmed
      registration_complete { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end
  end
end
