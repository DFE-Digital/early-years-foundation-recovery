# Defaults to dynamic schema using happy path for alpha
# but loads a YAML fixture instead if provided
#
# @example
#   Dynamic:
#
#     include_context 'with automated path'
#     let(:mod) { <Training::Module> }
#     let(:happy) { <Boolean> }
#
#   Static:
#
#     include_context 'with automated path'
#     let(:fixture) { 'spec/support/ast/bespoke-module-journey.yml' }
#
RSpec.shared_context 'with automated path' do
  let(:mod) { Training::Module.by_name(:alpha) }
  let(:happy) { true }
  # Or
  let(:fixture) { nil }

  let(:schema) do
    if fixture.present?
      YAML.load_file Rails.root.join(fixture)
    else
      ContentTestSchema.new(mod: mod).call(pass: happy).compact
    end
  end

  before do
    visit schema.first[:path]

    schema.each do |content|
      content[:inputs].each { |args| send(*args) }
    end
  end
end
