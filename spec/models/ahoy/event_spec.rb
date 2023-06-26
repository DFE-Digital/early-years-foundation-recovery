require 'rails_helper'

RSpec.describe Ahoy::Event, type: :model do
  subject(:events) { described_class }

  describe '.to_csv' do
    let(:coercion_decorator) { CoercionDecorator.new }
    before do
      described_class.new(
        id: 1,
        user_id: 1,
        visit: Ahoy::Visit.new(id: 2),
        name: 'module_start',
        properties: { foo: 'bar' },
        time: Time.zone.local(2023, 0o1, 12, 10, 15, 59),
      ).save!
    end

    it 'exports formatted attributes as CSV' do
      expect(described_class.to_csv(coercion_decorator)).to eq <<~CSV
        id,visit_id,user_id,name,properties,time
        1,2,1,module_start,"{""foo""=>""bar""}",2023-01-12 10:15:59
      CSV
    end
  end

  describe '.summative_assessment_pass' do
    it 'returns successful completion events' do
      create(:event, name: 'summative_assessment_complete', properties: { training_module_id: 'alpha', success: true })
      expect(events.summative_assessment_pass(:alpha).count).to be 1
      expect(events.summative_assessment_fail(:alpha).count).to be 0
    end
  end

  describe '.summative_assessment_fail' do
    it 'returns successful completion events' do
      create(:event, name: 'summative_assessment_complete', properties: { training_module_id: 'alpha', success: false })
      expect(events.summative_assessment_fail(:alpha).count).to be 1
      expect(events.summative_assessment_pass(:alpha).count).to be 0
    end
  end

  describe 'OR query' do
    before do
      create(:event, name: 'module_content_page', properties: { training_module_id: 'alpha', type: 'foo' })
      create(:event, name: 'module_content_page', properties: { training_module_id: 'bravo', type: 'bar' })
      create(:event, name: 'module_content_page', properties: { training_module_id: 'charlie', type: 'baz' })
    end

    describe '.where_page_type' do
      it 'returns page views of given property types' do
        expect(events.where_page_type(:foo).count).to be 1
        expect(events.where_page_type(:foo, :bar).count).to be 2
      end
    end

    describe '.where_module' do
      it 'returns named events for given modules' do
        expect(events.where_module(:alpha, :bravo).count).to be 2
        expect(events.where_module(:bravo).count).to be 1
      end
    end
  end

  describe 'user_registration' do
    before do
      create(:event, name: 'user_registration', properties: { controller: 'extra_registrations' }) # original journey
      create(:event, name: 'user_registration', properties: { controller: 'registration/role_types' })
      create(:event, name: 'user_registration', properties: { controller: 'registration/local_authorities' })
    end

    describe '.public_beta_registration' do
      it 'returns registration events for the revised journey' do
        expect(events.public_beta_registration.count).to be 2
      end
    end

    describe '.private_beta_registration' do
      it 'returns registration events for the revised journey' do
        expect(events.private_beta_registration.count).to be 1
      end
    end
  end
end
