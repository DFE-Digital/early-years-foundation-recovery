require 'rails_helper'

RSpec.describe ContentTestSchema do
  subject(:schema) { described_class.new(mod: alpha) }

  let(:alpha) { Training::Module.by_name(:alpha) }

  let(:ast) do
    YAML.load_file(Rails.root.join("spec/support/ast/alpha-#{fixture}.yml"))
  end

  context 'when pass is true' do
    let(:fixture) { 'pass-response-with-feedback' }

    specify do
      expect(schema.call).to eq ast
    end
  end

  context 'when pass is false' do
    let(:fixture) { 'fail-response' }

    specify do
      expect(schema.call(pass: false).compact).to eq ast
    end
  end
end
