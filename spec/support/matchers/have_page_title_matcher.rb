RSpec::Matchers.define :have_page_title do |title_suffix|
  match do |path|
    visit path
    page.title.eql? "Child development training : #{title_suffix}"
  end

  failure_message do |path|
    "expected #{path} to have title 'Child development training : #{title_suffix}', not '#{page.title}'"
  end

  description do
    "have title 'Child development training : #{title_suffix}'"
  end
end
