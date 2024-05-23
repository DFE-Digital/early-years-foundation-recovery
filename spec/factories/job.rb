FactoryBot.define do
  factory :job do
    job_class { 'Fake::Job' }
    job_schema_version { 2 }
  end
end
