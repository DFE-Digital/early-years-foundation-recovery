#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Use the official production OpenID Connect discovery endpoint by default
OPENID_CONFIG_URL = ENV['GOV_ONE_OPENID_CONFIG_URL'] || 'https://oidc.account.gov.uk/.well-known/openid-configuration'.freeze
CACHE_FILE = 'last_govuk_kids.json'.freeze
def http_get(uri)
  if ENV['INSECURE_SKIP_VERIFY'] == '1'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)
    response.body
  else
    Net::HTTP.get(uri)
  end
end

def discover_jwks_uri
  uri = URI(OPENID_CONFIG_URL)
  response = Net::HTTP.get(uri)
  json = JSON.parse(response)
  json['jwks_uri'] || 'https://oidc.account.gov.uk/.well-known/jwks.json'
rescue StandardError => e
  warn "Failed to fetch OpenID config: #{e.message}, using default JWKS URI"
  'https://oidc.account.gov.uk/.well-known/jwks.json'
end

def fetch_kids
  jwks_url = discover_jwks_uri
  uri = URI(jwks_url)
  response = http_get(uri)
  jwks = JSON.parse(response)
  jwks['keys'].map { |k| k['kid'] }
end

def load_last_kids
  return [] unless File.exist?(CACHE_FILE)

  JSON.parse(File.read(CACHE_FILE))
rescue StandardError
  []
end

def save_kids(kids)
  File.write(CACHE_FILE, kids.to_json)
end

def main
  current_kids = fetch_kids
  last_kids = load_last_kids

  new_kids = current_kids - last_kids
  removed_kids = last_kids - current_kids

  if new_kids.any? || removed_kids.any?
    puts 'Key rotation detected!'
    puts "New kids: #{new_kids.join(', ')}" if new_kids.any?
    puts "Removed kids: #{removed_kids.join(', ')}" if removed_kids.any?
  else
    puts "No key rotation detected. Current kids: #{current_kids.join(', ')}"
  end

  save_kids(current_kids)
end

main if __FILE__ == $PROGRAM_NAME
