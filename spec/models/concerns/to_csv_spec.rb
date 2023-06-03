require 'rails_helper'

RSpec.describe ToCsv do
  let(:to_csv) { Class.new { include ToCsv } }

  describe '.generate_csv' do
    context 'when given headers and data' do
      it 'returns a csv string' do
        headers = %w[header_1 header_2]
        data = [%w[data_1 data_2], %w[data_3 data_4]]
        expect(to_csv.generate_csv(headers, data)).to eq("header_1,header_2\ndata_1,data_2\ndata_3,data_4\n")
      end
    end

    context 'when given empty headers and data' do
      it 'returns an empty csv string' do
        headers = []
        data = []
        expect(to_csv.generate_csv(headers, data)).to eq("\n")
      end
    end
  end
end
