# Be sure to restart your server when you modify this file.
#
# Define an application-wide content security policy
# For further information see the following documentation
#
# - {https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy}
# - {https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP for more CSP info}
#
# The resulting policy should be checked with:
#
# - {https://csp-evaluator.withgoogle.com}
# - {https://cspvalidator.org}
#
# Add URLs in order to import images or javascript from another domain
#
GOOGLE_ANALYTICS_DOMAINS = %w[
  www.google-analytics.com
  ssl.google-analytics.com
  stats.g.doubleclick.net
  www.googletagmanager.com
  i.vimeocdn.com
  player.vimeo.com
  www.vimeo.com
].freeze

OPTIMIZE_DOMAINS = %w[
  www.googleoptimize.com
  optimize.google.com
  fonts.googleapis.com
].freeze

GOOGLE_STATIC_DOMAINS = %w[
  fonts.gstatic.com
  www.gstatic.com
].freeze

# c.bing.com is required for Clarity pixels delivered via Bing CDN
CLARITY_DOMAINS = %w[
  www.clarity.ms
  scripts.clarity.ms
  j.clarity.ms
  c.clarity.ms
  c.bing.com
].freeze

Rails.application.config.content_security_policy do |policy|
  # @see https://www.contentful.com/developers/docs/tutorials/general/live-preview/#set-up-live-preview
  policy.frame_ancestors :self, 'https://app.contentful.com'

  policy.default_src :none
  policy.base_uri    :self
  policy.form_action :self

  policy.font_src    :self,
                     *GOOGLE_STATIC_DOMAINS,
                     :data

  policy.frame_src   :self,
                     *GOOGLE_ANALYTICS_DOMAINS,
                     *OPTIMIZE_DOMAINS

  policy.img_src     :self,
                     *GOOGLE_ANALYTICS_DOMAINS, # Tracking pixels
                     *OPTIMIZE_DOMAINS,
                     *CLARITY_DOMAINS,
                     'images.ctfassets.net',
                     'github.com', # eyrecovery-dev.azurewebsites.net
                     :data # Base64 encoded images

  policy.media_src   :self,
                     'player.vimeo.com',
                     'i.vimeocdn.com'

  policy.object_src  :none

  policy.script_src  :self,
                     *GOOGLE_ANALYTICS_DOMAINS,
                     *GOOGLE_STATIC_DOMAINS,
                     *OPTIMIZE_DOMAINS,
                     *CLARITY_DOMAINS

  policy.style_src   :self,
                     *GOOGLE_STATIC_DOMAINS,
                     *OPTIMIZE_DOMAINS

  webpack_dev_server = %w[http://localhost:3035 ws://localhost:3035] if Rails.env.development?

  policy.connect_src :self,
                     *GOOGLE_ANALYTICS_DOMAINS,
                     *CLARITY_DOMAINS,
                     *webpack_dev_server.to_a

  policy.upgrade_insecure_requests
  policy.block_all_mixed_content
end

# If you are using UJS then enable automatic nonce generation
#
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
#
# Set the nonce only to specific directives
#
Rails.application.config.content_security_policy_nonce_directives = %w[script-src style-src]
#
# Report CSP violations to a specified URI
# For further information see the following documentation
#
# - {https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only}
#
Rails.application.config.content_security_policy_report_only = ENV.fetch('CSP_REPORT_ONLY', (!Rails.env.production?).to_s) == 'true'
