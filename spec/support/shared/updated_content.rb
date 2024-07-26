RSpec.shared_examples 'updated content' do
  it 'bar' do
    # binding.pry
    expect(subject.page_type).to eql nil
  end
end