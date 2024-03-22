require 'rails_helper'

RSpec.describe ContentTestSchema do
  subject(:schema) { described_class.new(mod: alpha) }

  let(:alpha) { Training::Module.by_name(:alpha) }

  let(:ast) do
    if Rails.application.migrated_answers?
      YAML.load_file(Rails.root.join("spec/support/ast/#{fixture}-response.yml"))
    else
      YAML.load_file(Rails.root.join("spec/support/ast/#{fixture}.yml"))
    end
  end

  context 'when pass is true' do
    let(:fixture) { 'alpha-pass-feedback-form' }

    specify do
      expect(schema.call).to eq ast
    end
  end

  context 'when pass is false' do
    let(:fixture) { 'alpha-fail-feedback-form' }

    specify do
      expect(schema.call(pass: false).compact).to eq ast
    end
  end
end
