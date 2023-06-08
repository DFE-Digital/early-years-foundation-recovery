require 'rails_helper'

RSpec.describe ToCsv do
  describe '.to_csv' do
    context 'when given headers and data' do
      subject(:klass) do
        Class.new do
          include ToCsv

          def self.column_names
            ['Custom Column 1', 'Custom Column 2']
          end

          def self.dashboard
            [%w[data_1 data_2], %w[data_3 data_4]]
          end
        end
      end

      it 'returns a csv string' do
        expect(klass.to_csv).to eq("Custom Column 1,Custom Column 2\ndata_1,data_2\ndata_3,data_4\n")
      end
    end

    context 'when given empty headers and data' do
      subject(:klass) do
        Class.new do
          include ToCsv

          def self.column_names
            []
          end

          def self.dashboard
            []
          end
        end
      end

      it 'returns an empty csv string' do
        expect(klass.to_csv).to eq("\n")
      end
    end
  end
end
