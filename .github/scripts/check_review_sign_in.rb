require 'cgi'
require 'uri'

def check_review_sign_in(page, base_url)
  page.scan(/<a\b[^>]*>/i).each do |anchor|
    attributes = CGI.unescapeHTML(anchor)
    match = attributes.match(/\bhref\s*=\s*(["'])(.*?)\1/i)
    next unless match

    href = match[2]
    next unless href.start_with?("#{base_url}/authorize?")

    query = URI.decode_www_form(URI.parse(href).query.to_s).to_h
    next unless query['redirect_uri'] == "#{base_url}/users/auth/openid_connect/callback"
    next unless query['response_type'] == 'code'
    next unless query['client_id']&.match?(/\Areview-pr-[1-9]\d*\z/)

    return true
  end

  raise ArgumentError, 'Exact review simulator authorize link and callback not found'
end

if $PROGRAM_NAME == __FILE__
  check_review_sign_in($stdin.read, ARGV.fetch(0))
end
