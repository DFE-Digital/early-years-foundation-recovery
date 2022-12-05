RSpec::Matchers.define :have_page_title do |title_suffix|
  match do |path|
    visit path
    page.title.eql? "Early years child development training : #{title_suffix}"
  end

  failure_message do |path|
    "expected #{path} to have title 'Early years child development training : #{title_suffix}', not '#{page.title}'"
  end

  description do
    "have title 'Early years child development training : #{title_suffix}'"
  end
end
