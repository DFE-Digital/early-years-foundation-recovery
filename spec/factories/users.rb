FactoryBot.define do
  factory :user do
    email { Faker::Internet.safe_email }
    password { 'StrongPassword123' }
    terms_and_conditions_agreed_at { Date.new(2000, 0o1, 0o1) }

    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end

    trait :registered do
      confirmed
      registration_complete { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      setting_type_id { SettingType.all.sample.id }
      role_type { RoleType.first.name }
      local_authority { LocalAuthority.first.name }
      terms_and_conditions_agreed_at { Date.new(2000, 0o1, 0o1) }
    end

    trait :completed do
      registered
      ofsted_number { 'EY123456' }
    end

    trait :name do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :setting_type do
      setting_type_id { SettingType.all.sample.id }
    end

    trait :setting_type_with_role_type do
      setting_type_id { SettingType.where(role_type: ['childminder', 'other']).sample.id }
    end

    trait :display_whats_new do
      display_whats_new { true }
    end
  end
end
