require 'rails_helper'
require 'migrate_training'

RSpec.describe 'Training response data migration', type: :system do
  include_context 'with user'
  include_context 'with progress'

  subject(:operation) { MigrateTraining.new(verbose: true) }

  before do
    skip if Rails.application.migrated_answers?

    # PASS ALPHA
    visit '/modules/alpha/content-pages/what-to-expect'

    ContentTestSchema.new(mod: alpha).call(pass: true).compact.each do |content|
      content[:inputs].each { |args| send(*args) }
    end

    visit '/modules/alpha/assessment-result/1-3-2-11'

    # FAIL BRAVO
    visit '/modules/bravo/content-pages/what-to-expect'

    ContentTestSchema.new(mod: bravo).call(pass: false).compact.each do |content|
      content[:inputs].each { |args| send(*args) }
    end

    visit '/modules/bravo/assessment-result/1-3-2-11'
  end

  it 'is successful' do
    expect(UserAssessment.count).to eq 2
    expect(Assessment.count).to be 0

    expect(UserAssessment.first.user_answers.count).to eq 10

    expect(UserAnswer.where(module: 'alpha').count).to be 17
    expect(UserAnswer.where(module: 'bravo').count).to be 11
    expect(Response.count).to be 0

    operation.call # <<<<<------------------------------------------------------

    expect(UserAssessment.count).to eq 2
    expect(Assessment.count).to be 2

    expect(UserAnswer.count).to be 28
    expect(Response.count).to be 28

    expect(Assessment.where(training_module: 'alpha').first.passed).to eq true
    expect(Assessment.where(training_module: 'alpha').first.score).to eq 100.0
    expect(Assessment.where(training_module: 'alpha').first.responses.count).to eq 10

    expect(Assessment.where(training_module: 'bravo').first.passed).to eq false
    expect(Assessment.where(training_module: 'bravo').first.score).to eq 0.0
    expect(Assessment.where(training_module: 'bravo').first.responses.count).to eq 10
  end

end
