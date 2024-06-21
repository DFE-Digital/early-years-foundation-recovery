require 'rails_helper'

RSpec.describe ContentTestSchema do
  subject(:schema) { described_class.new(mod: alpha) }

  let(:alpha) { Training::Module.by_name(:alpha) }

  let(:ast) do
    YAML.load_file(Rails.root.join("spec/support/ast/#{fixture}-response.yml"))
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
      expect(schema.call(pass: false).compact).to eq ast
    end
  end
end
