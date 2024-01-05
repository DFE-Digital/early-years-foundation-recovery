FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Rails.configuration.user_password }
    terms_and_conditions_agreed_at { Date.new(2000, 0o1, 0o1) }

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
      early_years_emails { false }
      registration_complete { true }
    end

    factory :gov_one_user do
      registered
      gov_one_id { 'urn:fdc:gov.uk:2022:23-random-alpha-numeric' }
      # password { nil }
    end

    # Personas -----------------------------------------------------------------

    trait :agency_childminder do
      registered
      setting_type_id { 'childminder_agency' }
      setting_type { 'Childminder as part of an agency' } # Why are we persisting the titles?
      setting_type_other { nil }
      role_type { 'Childminder' }
      role_type_other { nil }
    end

    trait :independent_childminder do
      registered
      setting_type_id { 'childminder_independent' }
      setting_type { 'Independent childminder' }
      setting_type_other { nil }
      role_type { 'Childminder' }
      role_type_other { nil }
    end
  end
end
