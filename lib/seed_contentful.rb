# :nocov:
require 'contentful/management'

# CMS client and factories with logging
# @see https://github.com/contentful/contentful-management.rb
#
class SeedContentful
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }

  # @see https://app.contentful.com/account/profile/cma_tokens
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

private

  # @param message [String]
  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end

  # @return [Contentful::Management::ClientContentTypeMethodsFactory]
  def content_types
    @content_types ||= client.content_types(config.space, config.environment)
  end

  # @return [Contentful::Management::ClientAssetMethodsFactory]
  def assets
    @assets ||= client.assets(config.space, config.environment)
  end

  # @param description [String]
  # @return [Contentful::Management::Asset]
  def find_asset(description)
    assets.all(limit: 1_000).find { |asset| asset.description.eql?(description) }
  end
end
# :nocov:
