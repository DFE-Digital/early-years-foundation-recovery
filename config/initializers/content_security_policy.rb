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
# '*.s3.eu-west-2.amazonaws.com',
# 'eyfs-cms-preprod.london.cloudapps.digital',
GOVUK_DOMAINS = %w[
  *.education.gov.uk
].freeze

GOOGLE_ANALYTICS_DOMAINS = %w[
  www.google-analytics.com
  ssl.google-analytics.com
  stats.g.doubleclick.net
  www.googletagmanager.com
  *.hotjar.com
  *.ytimg.com
  www.youtube.com
  www.youtube-nocookie.com
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

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self,
                     :https,
                     *GOVUK_DOMAINS
  policy.font_src    :self,
                     :https,
                     *GOVUK_DOMAINS,
                     *GOOGLE_STATIC_DOMAINS,
                     :data
  policy.frame_src   :self,
                     *GOOGLE_ANALYTICS_DOMAINS,
                     *OPTIMIZE_DOMAINS
  policy.img_src     :self,
                     *GOVUK_DOMAINS,
                     *GOOGLE_ANALYTICS_DOMAINS, # Tracking pixels
                     *OPTIMIZE_DOMAINS,
                     :data # Base64 encoded images
  policy.object_src  :none
  policy.script_src  :self,
                     *GOVUK_DOMAINS,
                     *GOOGLE_ANALYTICS_DOMAINS,
                     *GOOGLE_STATIC_DOMAINS,
                     *OPTIMIZE_DOMAINS,
                     # Allow all inline scripts until we can conclusively
                     # document all the inline scripts we use,
                     # and there's a better way to filter out junk reports
                     :unsafe_inline
  policy.style_src   :self,
                     *GOVUK_DOMAINS,
                     *GOOGLE_STATIC_DOMAINS,
                     *OPTIMIZE_DOMAINS,
                     :unsafe_inline
  if Rails.env.development?
    # :nocov: by definition will not run in test
    policy.connect_src :self,
                       :https,
                       :wss,
                       *GOVUK_DOMAINS,
                       *GOOGLE_ANALYTICS_DOMAINS,
                       'http://localhost:3035',
                       'ws://localhost:3035'
    # :nocov:
  else
    policy.connect_src :self,
                       :https,
                       :wss,
                       *GOVUK_DOMAINS,
                       *GOOGLE_ANALYTICS_DOMAINS
  end
end

# If you are using UJS then enable automatic nonce generation
#
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
#
# Set the nonce only to specific directives
#
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
#
# Report CSP violations to a specified URI
# For further information see the following documentation
#
# - {https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only}
#
# Rails.application.config.content_security_policy_report_only = true
