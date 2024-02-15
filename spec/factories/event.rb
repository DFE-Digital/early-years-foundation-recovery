FactoryBot.define do
  factory :event do
    user
    name { 'module_content_page' }
    properties { {} }
    time { Time.zone.now }

    # FIXME: event.user != visit.user
    association :visit, factory: :visit
  end
end
