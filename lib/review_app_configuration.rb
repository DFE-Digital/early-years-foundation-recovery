module ReviewAppConfiguration
  def self.enabled?(env)
    enabled = env['GOV_ONE_SIMULATOR'] == 'true'
    review = env['ENVIRONMENT'] == 'review'
    return false unless enabled || review

    unless enabled && review && env['WEBSITE_SLOT_NAME'].to_s.match?(/\Apr-[1-9]\d*\z/)
      raise 'One Login simulator is only permitted in PR review slots'
    end

    unless env['GOV_ONE_BASE_URI'] == "https://#{env.fetch('DOMAIN')}"
      raise 'Review simulator must use the review app HTTPS hostname'
    end

    raise 'Review signing key must not be empty' if env.fetch('GOV_ONE_PRIVATE_KEY').strip.empty?
    unless env.fetch('GOV_ONE_CLIENT_ID') == "review-#{env['WEBSITE_SLOT_NAME']}"
      raise 'Review client ID must be unique to the PR slot'
    end

    true
  end
end
