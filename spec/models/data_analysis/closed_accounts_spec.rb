require 'rails_helper'

RSpec.describe DataAnalysis::ClosedAccounts do
  let(:headers) do
    [
      'User ID',
      'Closed',
      'Setting',
      'Custom setting',
      'Role',
      'Custom role',
      'Reason',
      'Custom reason',
    ]
  end

  let(:rows) do
    [
      # default
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'not useful',
        closed_reason_custom: nil,
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'no time',
        closed_reason_custom: nil,
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'no longer in early years',
        closed_reason_custom: nil,
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'too many emails',
        closed_reason_custom: nil,
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'prefer not to say',
        closed_reason_custom: nil,
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      # custom
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'other',
        closed_reason_custom: 'I did not find the training useful',
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'other',
        closed_reason_custom: 'I did not find the training useful',
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
      {
        closed_at: '2024-01-08 10:23:40',
        closed_reason: 'other',
        closed_reason_custom: 'I know everything',
        role_type: 'other',
        role_type_other: 'Developer',
        setting_type: nil,
        setting_type_other: 'DfE',
      },
    ]
  end

  before do
    # active
    create :user, :named
    create :user, :registered
    # default
    create :user, :closed, closed_reason_custom: nil, closed_reason: 'not useful'
    create :user, :closed, closed_reason_custom: nil, closed_reason: 'no time'
    create :user, :closed, closed_reason_custom: nil, closed_reason: 'no longer in early years'
    create :user, :closed, closed_reason_custom: nil, closed_reason: 'too many emails'
    create :user, :closed, closed_reason_custom: nil, closed_reason: 'prefer not to say'
    # custom
    create :user, :closed
    create :user, :closed
    create :user, :closed, closed_reason: 'other', closed_reason_custom: 'I know everything'
  end

  it 'has correct headers' do
    expect(described_class.column_names).to eq(headers)
  end

  it 'has user ids' do
    dashboard_data = described_class.dashboard
    expect(dashboard_data).to all(include(:user_id))
  end

  it 'matches expected data' do
    # Compare everything else except user_id
    dashboard_data = described_class.dashboard
    actual_rows_without_id = dashboard_data.map { |r| r.except(:user_id) }
    expect(actual_rows_without_id).to match_array(rows.map { |r| r.except(:user_id) })
  end
end
