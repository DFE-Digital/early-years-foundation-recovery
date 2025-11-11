require 'rails_helper'

RSpec.describe Trainee::Setting do
  describe '.by_name' do
    it "returns OpenStruct with flags for 'other'" do
      result = described_class.by_name('other')
      expect(result).to respond_to(:local_authority?)
      expect(result).to respond_to(:has_role?)
      expect(result.local_authority?).to be true
      expect(result.has_role?).to be true
    end
  end

  describe '.valid_types' do
    context 'when contentful space is nil (e.g. build time)' do
      it 'returns empty array' do
        allow(Rails.application.config).to receive(:contentful_space).and_return(nil)
        expect(described_class.valid_types).to eq []
      end
    end

    context 'with active settings present' do
      it 'returns active names plus other' do
        allow(Rails.application.config).to receive(:contentful_space).and_return('space')
        setting_struct = Struct.new(:name)
        allow(described_class).to receive(:active).and_return([
          setting_struct.new('alpha'),
          setting_struct.new('beta'),
        ])

        expect(described_class.valid_types).to match_array %w[alpha beta other]
      end
    end
  end

  describe '.allowed_name?' do
    it "returns true for 'other'" do
      expect(described_class.allowed_name?('other')).to be true
    end

    it 'returns true for a name in .all' do
      setting_struct = Struct.new(:name)
      allow(described_class).to receive(:all).and_return([
        setting_struct.new('nursery'),
      ])
      expect(described_class.allowed_name?('nursery')).to be true
    end

    it 'returns false for an unknown name' do
      allow(described_class).to receive(:all).and_return([])
      expect(described_class.allowed_name?('unknown')).to be false
    end
  end

  describe '.with_roles' do
    it 'filters active settings to only those with a role' do
      setting_struct = Struct.new(:name, :has_role_flag) do
        def has_role?
          has_role_flag
        end
      end

      allow(described_class).to receive(:active).and_return([
        setting_struct.new('childminder', true),
        setting_struct.new('training_provider', false),
      ])

      result = described_class.with_roles
      expect(result.map(&:name)).to eq %w[childminder]
    end
  end

  describe '.active' do
    it 'returns only settings that are active?' do
      setting_struct = Struct.new(:name, :active) do
        def active?
          ActiveModel::Type::Boolean.new.cast(active)
        end
      end

      allow(described_class).to receive(:all).and_return([
        setting_struct.new('a', true),
        setting_struct.new('b', false),
      ])

      expect(described_class.active.map(&:name)).to eq %w[a]
    end
  end

  describe '.by_role' do
    it 'delegates to find_by and returns an array' do
      allow(described_class).to receive(:find_by).with(role_type: 'trainer').and_return(%i[one two])
      expect(described_class.by_role('trainer')).to eq %i[one two]
    end
  end
end
