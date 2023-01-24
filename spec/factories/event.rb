FactoryBot.define do
  factory :event, class: 'Ahoy::Event' do
    user
    name { 'module_content_page' }
    properties { {} }
    time { Time.zone.now }

    # FIXME: event.user != visit.user
    association :visit, factory: :visit
  end
end
