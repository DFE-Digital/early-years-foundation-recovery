FactoryBot.define do
  factory :user_module_progress do
    user
    module_name { 'alpha' }
    started_at { Time.zone.now }
    completed_at { nil }
    visited_pages { {} }
    last_page { nil }

    trait :completed do
      completed_at { Time.zone.now }
    end

    trait :in_progress do
      completed_at { nil }
    end

    trait :with_pages do
      visited_pages { { 'what-to-expect' => Time.zone.now.iso8601, '1-1' => Time.zone.now.iso8601 } }
      last_page { '1-1' }
    end
  end
end
