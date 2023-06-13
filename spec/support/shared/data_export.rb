RSpec.shared_examples 'a data export model' do
  let(:headers) do
    []
  end
  let(:rows) do
    []
  end

  specify { expect(described_class.column_names).to eq(headers) }
  specify { expect(described_class.dashboard).to eq(rows) }
end
