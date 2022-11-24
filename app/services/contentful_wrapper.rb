require 'contentful'

class ContentfulWrapper
  # Gets or creates a Contentful Service Wrapper
  #
  # @param space_id [String]
  # @param delivery_token [String]
  # @param preview_token [String]
  #
  # @return [Services::Contentful]
  def self.instance(space_id, delivery_token, preview_token, host = nil)
    @instance ||= nil

    # We create new client instances only if credentials changed or client wasn't instantiated before
    if @instance.nil? ||
        @instance.space_id != space_id ||
        @instance.delivery_token != delivery_token ||
        @instance.preview_token != preview_token ||
        @instance.host != host

      @instance = new(space_id, delivery_token, preview_token, host)
    end

    @instance
  end

  # Creates a Contentful client
  #
  # @param space_id [String]
  # @param access_token [String] Delivery or Preview API access token
  # @param is_preview [Boolean] wether or not the client uses the Preview API
  #
  # @return [::Contentful::Client]
  def self.create_client(space_id, access_token, is_preview = false, host = nil)
    host ||= 'contentful'

    options = {
      space: space_id,
      access_token: access_token,
      environment: 'master',
      dynamic_entries: :auto,
      raise_errors: true,
      application_name: 'child-development-training',
      application_version: '0.0.1',
      api_url: "cdn.#{host}.com",
      raw_mode: true
    }
    options[:api_url] = "preview.#{host}.com" if is_preview

    ::Contentful::Client.new(options)
  end

  attr_reader :space_id, :delivery_token, :preview_token, :host

  # Returns the corresponding client (Delivery or Preview)
  #
  # @param api_id [String]
  #
  # @return [::Contentful::Client]
  def client(api_id)
    api_id == 'cpa' ? @preview_client : @delivery_client
  end

  # Returns the current space
  #
  # @param api_id [String]
  #
  # @return [::Contentful::Space]
  def space(api_id)
    client(api_id).space
  end

  # Returns the current available locales
  #
  # @param api_id [String]
  #
  # @return [::Contentful::Array<::Contentful::Locale>]
  def locales(api_id)
    client(api_id).locales
  end

  # Finds all modules, optionally filters them
  #
  # @param api_id [String]
  # @param locale [String]
  # @param options [Hash] filters for the Search API
  #
  # @return [Array<::Contentful::Entry>]
  def modules(api_id, locale = 'en-US', options = {})
    options = {
      content_type: 'module',
      locale: locale,
      order: '-sys.createdAt',
      include: 6
    }.merge(options)

    client(api_id).entries(options)
  end

  # Finds a module by slug
  #
  # @param slug [String]
  # @param api_id [String]
  # @param locale [String]
  #
  # @return [::Contentful::Entry]
  def module(slug, api_id, locale = 'en-US')
    modules(api_id, locale, 'fields.slug' => slug)[0]
  end

  # Returns an entry by ID
  #
  # @param entry_id [String]
  # @param api_id [String]
  #
  # @return [::Contentful::Entry]
  def entry(entry_id, api_id)
    client(api_id).entry(entry_id)
  end

  private

  def initialize(space_id, delivery_token, preview_token, host = nil)
    @space_id = space_id
    @delivery_token = delivery_token
    @preview_token = preview_token
    @host = host

    @delivery_client = self.class.create_client(@space_id, @delivery_token, false, @host)
    @preview_client = self.class.create_client(@space_id, @preview_token, true, @host)
  end
end