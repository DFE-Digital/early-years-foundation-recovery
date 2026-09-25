require 'rails_helper'

RSpec.describe ContentIntegrity do
  context 'when module is not specified' do
    it 'raises constraint error' do
      expect { described_class.new(module_name: nil) }.to raise_error Dry::Types::ConstraintError
    end
  end

  describe '#valid?' do
    context 'when valid' do
      specify { expect(described_class.new(module_name: 'alpha')).to be_valid }
      specify { expect(described_class.new(module_name: 'bravo')).to be_valid }
      specify { expect(described_class.new(module_name: 'charlie')).to be_valid }
    end

    context 'when invalid' do
      specify { expect(described_class.new(module_name: 'delta')).not_to be_valid }
    end
  end

  describe 'page structure validation' do
    let(:pages) do
      %w[topic_intro certificate interruption_page sub_module_intro thankyou].map do |page_type|
        page = Training::Page.allocate
        page.define_singleton_method(:page_type) { page_type }
        page
      end
    end
    let(:mod) do
      page_list = pages
      mod = Training::Module.allocate
      mod.define_singleton_method(:pages) { page_list }
      mod.define_singleton_method(:topic_count) { 1 }
      mod.define_singleton_method(:submodule_count) { 1 }
      mod
    end

    before do
      allow(Training::Module).to receive(:by_name).with('unordered').and_return(mod)
    end

    it 'finds required page types regardless of their position' do
      integrity = described_class.new(module_name: 'unordered')

      expect(integrity).to be_interruption
      expect(integrity).to be_submodule
      expect(integrity).to be_topic
      expect(integrity).to be_thankyou
      expect(integrity).to be_certificate
    end
  end
end
