FactoryBot.define do
  factory :note do
    title { 'Note title' }
    body { 'Note body' }
    training_module { 'alpha' }
    name { '1-1-1-1' }
    user
  end
end
