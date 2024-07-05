require 'rails_helper'

RSpec.describe FormBuilder do
  let(:assigns) { {} }
  let(:controller) { ActionController::Base.new }
  let(:lookup_context) { ActionView::LookupContext.new(nil) }
  let(:helper) { ActionView::Base.new(lookup_context, assigns, controller) }
  let(:object) { create :user }
  let(:object_name) { :user }
  let(:builder) { described_class.new(object_name, object, helper, {}) }

  describe '#select_trainee_setting' do
    subject(:output) { builder.select_trainee_setting }

    it 'element' do
      expect(output).to include '<div class="govuk-form-group"'
      expect(output).to include 'name="user[setting_type_id]"'
    end

    it 'accessible label' do
      expect(output).to include 'Setting type'
    end

    it 'auto complete' do
      expect(output).to include 'No setting found'
    end

    it 'hint' do
      expect(output).to include 'Search for the type of setting or organisation you work in'
    end

    it 'options' do
      options = YAML.load_file Rails.root.join('data/setting-type.yml')
      expect(output).to include(*options.map { |s| s['name'] })
    end
  end
end
