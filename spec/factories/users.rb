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
      postcode { Faker::Address.postcode }
      setting_type { 'school' }
    end

    trait :completed do
      registered
      ofsted_number { 'EY123456' }
    end

    trait :display_whats_new do
      display_whats_new {true}
    end
  end
end
