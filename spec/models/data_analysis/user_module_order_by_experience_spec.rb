require 'rails_helper'

RSpec.describe DataAnalysis::UserModuleOrderByExperience do
  let(:headers) do
    %w[
      Experience
      UserId
      ModuleName
      FirstAccessedAt
      Order
    ]
  end

  # We'll build the expected rows dynamically after creating users/assessments
  let(:rows) do
    all_rows = []

    users.each do |user|
      # Sort assessments by started_at to determine order
      user.assessments.order(:started_at).each_with_index do |assessment, index|
        all_rows << {
          experience: user.early_years_experience,
          user_id: user.id,
          module_name: assessment.training_module,
          first_accessed_at: assessment.started_at,
          order: index + 1,
        }
      end
    end

    all_rows
  end

  # Create multiple users with different experience levels
  let!(:users) do
    [
      create(:user, early_years_experience: '0-2'),
      create(:user, early_years_experience: '3-5'),
      create(:user, early_years_experience: '5+'),
    ]
  end

  before do
    # User 0-2 completes modules in order
    create(:assessment, user: users[0], training_module: 'Intro', started_at: 3.days.ago)
    create(:assessment, user: users[0], training_module: 'Safety', started_at: 2.days.ago)
    create(:assessment, user: users[0], training_module: 'Compliance', started_at: 1.day.ago)

    # User 3-5 completes modules out of order
    create(:assessment, user: users[1], training_module: 'Safety', started_at: 4.days.ago)
    create(:assessment, user: users[1], training_module: 'Intro', started_at: 3.days.ago)

    # User 5+ completes only one module
    create(:assessment, user: users[2], training_module: 'Leadership', started_at: 2.days.ago)
  end

  it_behaves_like 'a data export model'

  # Extra tests to cover edge cases
  it 'orders assessments correctly per user' do
    grouped = described_class.dashboard.group_by { |row| row[:user_id] }

    # User 0-2 should have modules in order Intro -> Safety -> Compliance
    expect(grouped[users[0].id].map { |r| r[:module_name] }).to eq(%w[Intro Safety Compliance])

    # User 3-5 should have modules ordered by started_at
    expect(grouped[users[1].id].map { |r| r[:module_name] }).to eq(%w[Safety Intro])

    # User 5+ has only one module
    expect(grouped[users[2].id].map { |r| r[:module_name] }).to eq(%w[Leadership])
  end
end
