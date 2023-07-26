require 'rails_helper'

RSpec.describe Data::TrainingEmailRecipients do
  let(:headers) do
    %w[Email]
  end

  let(:rows) do
    [
      {
        email: 'test1@test.com',
      },
      {
        email: 'test2@test.com',
      },
    ]
  end

  before do
    create(:user, :registered, email: 'test1@test.com', training_emails: true)
    create(:user, :registered, email: 'test2@test.com')
    create(:user, :registered, email: 'test3@test.com', training_emails: false)
  end

  it_behaves_like('a data export model')

  it 'creates a csv file' do
    described_class.export_csv
    file_path = Rails.root.join('tmp/training_email_recipients.csv')
    expect(File.exist?(file_path)).to be true
    expect(File.read(file_path).split("\n").last).to eq('test2@test.com')
  end
end
