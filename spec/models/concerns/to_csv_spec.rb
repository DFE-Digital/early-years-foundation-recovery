require 'rails_helper'

RSpec.describe ToCsv do
  describe '.to_csv' do
    context 'when .dashboard_headers or .dashboard are undefined' do
      subject(:klass) do
        Class.new do
          include ToCsv
        end
      end

      specify do
        expect { klass.to_csv }.to raise_error ToCsv::ExportError
      end
    end

    context 'when .dashboard_headers and .dashboard are empty' do
      subject(:klass) do
        Class.new do
          include ToCsv

          def self.dashboard_headers
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

    context 'when .dashboard_headers and .dashboard are populated' do
      subject(:klass) do
        Class.new do
          include ToCsv
          def self.dashboard_headers
            %w[
              Uncoerced
              Coerced
            ]
          end

          def self.dashboard
            [
              {
                string: 'A Half',
                as_percentage: 0.5,
              },
              {
                string: 'A Third',
                as_percentage: 1.0 / 3,
              },
            ]
          end
        end
      end

      it 'returns a formatted csv string' do
        expect(klass.to_csv).to eq <<~CSV
          Uncoerced,Coerced
          A Half,50.0%
          A Third,33.33%
        CSV
      end
    end

    describe 'when using a custom batch size' do
      before do
        create_list :user_answer, 5, :questionnaire, :confidence
        create_list :event, 5, name: 'module_start'
      end

      it 'exports all rows' do
        expect(UserAnswer.to_csv(batch_size: 2).split("\n").count).to eq(6)
        expect(Ahoy::Event.to_csv(batch_size: 2).split("\n").count).to eq(6)
      end
    end
  end
end
