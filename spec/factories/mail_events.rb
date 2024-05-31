FactoryBot.define do
  factory :mail_event do
    user
    template { 'xxxxxxxx' }
    personalisation { {} }
    callback { {} }
  end
end
