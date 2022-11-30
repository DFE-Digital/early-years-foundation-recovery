class Upload
  require 'contentful/management'

  attr_reader :client, :space, :token, :environment
 
  def initialize
    @space = Rails.configuration.space
    @token = Rails.configuration.management_token
    @environment = 'master'
    @client = Contentful::Management::Client.new(token)
  end

  def call
    log client.configuration
    log "space: #{space}"

    mod = client.content_types(space, 'master').find('module')
    mod.activate

    page = client.content_types(space, 'master').find('page')
    page.activate
    
    TrainingModule.all.each do |tm|
      log "creating #{tm.name}"

      module_entry = mod.entries.create(
        id: tm.id,
        title: tm.title,
        slug: tm.name,
        short_description: tm.short_description,
        description: tm.description,
        duration: tm.duration,
        summative_threshold: tm.summative_threshold
      )

      pages = tm.module_items.map do |item|
        page.entries.create(
          slug: item.name,
          module_id: tm.name,
          component: item.type,
          heading: item.model&.heading,
          body: item.model&.body,
          notes: item.model&.notes
        )
      end

      module_entry.pages = pages
      module_entry.save
    end
  end

  private
  
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
