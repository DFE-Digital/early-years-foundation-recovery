RSpec.shared_examples 'a data export model' do
  specify { expect(described_class.dashboard_headers).to eq(headers) }
  specify { expect(described_class.dashboard).to eq(rows) }
end
