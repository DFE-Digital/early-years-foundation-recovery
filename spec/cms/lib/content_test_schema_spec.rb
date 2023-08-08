require 'rails_helper'
require 'content_test_schema'

RSpec.describe ContentTestSchema, :cms do
  subject(:schema) { described_class.new(mod: alpha) }

  let(:alpha) { Training::Module.by_name(:alpha) }

  let(:ast) do
    YAML.load_file(Rails.root.join("spec/support/ast/#{fixture}.yml"))
  end

  before do
    skip 'CMS ONLY' unless Rails.application.cms?
    skip 'WIP' if ENV['DISABLE_USER_ANSWER'].present?
  end

  context 'when pass is true' do
    let(:fixture) { 'alpha-pass' }

    specify do
      expect(schema.call).to eq ast
    end
  end

  context 'when pass is false' do
    let(:fixture) { 'alpha-fail' }

    specify do
      expect(schema.call(pass: false)).to eq ast
    end
  end
end
