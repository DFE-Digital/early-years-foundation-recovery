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
            [
              {
                custom_column_1: 'data_1',
                custom_column_2: 'data_2',
              },
              {
                custom_column_1: 'data_3',
                custom_column_2: 'data_4',
              },
            ]
          end
        end
      end

      it 'returns a csv string' do
        expect(klass.to_csv).to eq("Custom Column 1,Custom Column 2\ndata_1,data_2\ndata_3,data_4\n")
      end
    end

    context 'when .column_names or .dashboard are undefined' do
      subject(:klass) do
        Class.new do
          include ToCsv
        end
      end

      specify do
        expect { klass.to_csv }.to raise_error ToCsv::ExportError
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
            [
              {
                custom_column_1: 'data_1',
                custom_column_percentage: 0.5,
                custom_column_2: 'data_3',
                custom_column_3: 'data_5',
              },
              {
                custom_column_1: 'data_2',
                custom_column_percentage: 0.5,
                custom_column_2: 'data_4',
                custom_column_3: 'data_6',
              },
            ]
          end
        end
      end

      it 'returns a csv string' do
        expect(klass.to_csv).to eq("Custom Column 1,Custom Column Percentage,Custom Column 2,Custom Column 3\ndata_1,50.0%,data_3,data_5\ndata_2,50.0%,data_4,data_6\n")
      end
    end

    context 'when using a custom batch size' do
      describe 'it returns a csv string of the records' do
        subject(:events) do
          Ahoy::Event
        end

        before do
          events.new(
            id: 1,
            user_id: 1,
            visit: Ahoy::Visit.new(id: 1),
            name: 'module_start',
            properties: { foo: 'bar' },
            time: Time.zone.local(2023, 0o1, 12, 10, 15, 59),
          ).save!
          events.new(
            id: 2,
            user_id: 2,
            visit: Ahoy::Visit.new(id: 2),
            name: 'module_start',
            properties: { foo: 'bar' },
            time: Time.zone.local(2023, 0o1, 12, 10, 16, 59),
          ).save!
          events.new(
            id: 3,
            user_id: 3,
            visit: Ahoy::Visit.new(id: 3),
            name: 'module_start',
            properties: { foo: 'bar' },
            time: Time.zone.local(2023, 0o1, 12, 10, 17, 59),
          ).save!
        end

        it 'exports formatted attributes as CSV' do
          expect(events.to_csv(batch_size: 2)).to eq <<~CSV
            id,visit_id,user_id,name,properties,time
            1,1,1,module_start,"{""foo""=>""bar""}",2023-01-12 10:15:59
            2,2,2,module_start,"{""foo""=>""bar""}",2023-01-12 10:16:59
            3,3,3,module_start,"{""foo""=>""bar""}",2023-01-12 10:17:59
          CSV
        end
      end
    end
  end
end
