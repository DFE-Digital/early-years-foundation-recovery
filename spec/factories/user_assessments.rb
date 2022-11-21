FactoryBot.define do
  factory :user_assessment do
    score { 0 }
    assessments_type { 'summative_assessment' }
  end
end
