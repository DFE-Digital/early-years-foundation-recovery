RSpec.describe 'E2E' do
  include_context 'with user'

  include Capybara::DSL

  let(:ast) do
    YAML.load_file('ui/support/ast/child-development-and-the-eyfs.yml')
  end

  def make_note(field, input)
    fill_in field, with: input
  end

  before do
    skip 'WIP' unless ENV['E2E']

    click_on 'Module 1: Understanding child development and the EYFS'
    click_on 'Start module'
  end

  it 'completes the module' do
    ast.each do |content|
      expect(page).to have_current_path content[:path]
      expect(page).to have_content content[:text]
      content[:inputs].each { |args| send(*args) }
    end
  end
end
