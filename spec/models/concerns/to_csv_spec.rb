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
            {
              'Custom Column 1' => %w[data_1 data_3],
              'Custom Column 2' => %w[data_2 data_4],
            }
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

    context 'when given column names and hash data' do
      subject(:klass) do
        Class.new do
          include ToCsv
          def self.column_names
            ['Custom Column 1', 'Custom Column Percentage', 'Custom Column 2', 'Custom Column 3']
          end

          def self.dashboard
            {
              'Custom Column 1' => %w[data_1 data_2],
              'Custom Column percentage' => [0.5, 0.5],
              'Custom Column 2' => %w[data_3 data_4],
              'Custom Column 3' => %w[data_5 data_6],
            }
          end
        end
      end

      it 'returns a csv string' do
        expect(klass.to_csv).to eq("Custom Column 1,Custom Column Percentage,Custom Column 2,Custom Column 3\ndata_1,50.0%,data_3,data_5\ndata_2,50.0%,data_4,data_6\n")
      end
    end
  end
end
