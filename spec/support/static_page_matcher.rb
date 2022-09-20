RSpec::Matchers.define :be_successful do
  match do |path|
    get path
    expect(response).to have_http_status(:success)
  end

  description do
    'to render and return http status success.'
  end
end
