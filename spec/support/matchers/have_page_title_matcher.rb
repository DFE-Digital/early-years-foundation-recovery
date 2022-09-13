RSpec::Matchers.define :have_page_title do |expected_page_title|
  match do |path|
    visit path
    page.title.eql? "Child development training : #{expected_page_title}"
  end

  failure_message do |path|
    "expected when visiting #{path} to have title #{expected_page_title}, not #{page.title} "
  end
end
