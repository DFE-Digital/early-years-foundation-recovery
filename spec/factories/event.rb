FactoryBot.define do
  factory :event do
    user
    name { 'module_content_page' }
    properties { {} }
    time { Time.zone.now }

    trait :feedback_complete do
      name { 'feedback_complete' }
    end

    # FIXME: event.user != visit.user
    association :visit, factory: :visit
  end
end
