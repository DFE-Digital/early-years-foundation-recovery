# Dynamic AST schema which supports future changes to content
RSpec.shared_context 'with automated path' do
  include_context 'with progress'
  include_context 'with user'

  let(:mod) { alpha }
  let(:happy) { true }

  let(:schema) do
    ContentTestSchema.new(mod: mod).call(pass: happy).compact
  end

  before do
    visit "/modules/#{mod.name}/content-pages/what-to-expect"

    schema.each do |content|
      # puts content[:path]
      content[:inputs].each { |args| send(*args) }
    end
  end
end

# Static file export of AST schema answered correctly
RSpec.shared_context 'with alpha happy path' do
  include_context 'with progress'
  include_context 'with user'

  let(:mod) { alpha }

  let(:schema) do
    if Rails.application.migrated_answers?
      YAML.load_file Rails.root.join('spec/support/ast/alpha-pass-response.yml')
    else
      YAML.load_file Rails.root.join('spec/support/ast/alpha-pass.yml')
    end
  end

  before do
    visit '/modules/alpha/content-pages/what-to-expect'

    schema.each do |content|
      # puts content[:path]
      content[:inputs].each { |args| send(*args) }
    end
  end
end

# Static file export of AST schema answered incorrectly
RSpec.shared_context 'with alpha unhappy path' do
  include_context 'with progress'
  include_context 'with user'

  let(:mod) { alpha }

  let(:schema) do
    if Rails.application.migrated_answers?
      YAML.load_file Rails.root.join('spec/support/ast/alpha-fail-response.yml')
    else
      YAML.load_file Rails.root.join('spec/support/ast/alpha-fail.yml')
    end
  end

  before do
    visit '/modules/alpha/content-pages/what-to-expect'

    schema.each do |content|
      # puts content[:path]
      content[:inputs].each { |args| send(*args) }
    end
  end
end
