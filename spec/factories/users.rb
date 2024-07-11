FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Rails.configuration.user_password }
    terms_and_conditions_agreed_at { Date.new(2000, 0o1, 0o1) }
    gov_one_id { "urn:fdc:gov.uk:2022:23-#{Faker::Alphanumeric.alphanumeric(number: 10)}" }

    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end

    trait :named do
      confirmed
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :registered do
      named
      setting_type_id { 'other' }
      setting_type { nil }
      setting_type_other { 'DfE' }
      role_type { 'other' }
      role_type_other { 'Developer' }
      # local_authority { '' }
      training_emails { true }
      registration_complete { true }
    end

    trait :closed do
      registered
      closed_at { '2024-01-08 10:23:40' }
      closed_reason { 'other' }
      closed_reason_custom { 'I did not find the training useful' }
    end

    # Personas -----------------------------------------------------------------

    trait :agency_childminder do
      registered
      setting_type_id { 'childminder_agency' }
      setting_type { 'Childminder as part of an agency' }
      setting_type_other { nil }
      role_type { 'Childminder' }
      role_type_other { nil }
      early_years_experience { '6-9' }
      local_authority { 'Hertfordshire' }
    end

    trait :independent_childminder do
      registered
      setting_type_id { 'childminder_independent' }
      setting_type { 'Independent childminder' }
      setting_type_other { nil }
      role_type { 'Childminder' }
      role_type_other { nil }
      early_years_experience { '0-2' }
      local_authority { 'Leeds' }
    end

    trait :team_member do
      registered
      sequence(:email) { |n| "person#{n}@education.gov.uk" }
    end
  end
end
