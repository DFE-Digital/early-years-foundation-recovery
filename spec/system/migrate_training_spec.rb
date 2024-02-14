require 'rails_helper'
require 'migrate_training'

RSpec.describe 'Training response data migration', type: :system do
  include_context 'with user'
  include_context 'with progress'

  subject(:operation) { MigrateTraining.new(verbose: true) }

  let(:alpha_assessment) { Assessment.where(training_module: 'alpha').first }
  let(:bravo_assessment) { Assessment.where(training_module: 'bravo').first }

  let(:ast) do
    YAML.load_file Rails.root.join('spec/support/ast/training-migration.yml')
  end

  before do
    skip if Rails.application.migrated_answers?

    visit '/my-modules'

    ast.each do |content|
      expect(page).to have_current_path content[:path]
      expect(page).to have_content content[:text]

      content[:inputs].each { |args| send(*args) }
    end
  end

  # alpha pass then bravo fail
  #
  it 'is successful' do

    # data = ContentTestSchema.new(mod: bravo).call(pass: false).compact
    # file = Rails.root.join('spec/support/ast/bravo-fail.yml')
    # File.open(file, 'w') { |file| file.write(data.to_yaml) }

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

    expect(alpha_assessment.passed).to eq true
    expect(alpha_assessment.score).to eq 100.0
    expect(alpha_assessment.responses.count).to eq 10

    expect(bravo_assessment.passed).to eq false
    expect(bravo_assessment.score).to eq 0.0
    expect(bravo_assessment.responses.count).to eq 10
  end

end
