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

    training_module = client.content_types(space, 'master').create(
      id: 'module',
      name: 'training module',
      description: 'Training module'
    )

    item_page = client.content_types(space, 'master').create(
      id: 'page',
      name: 'content page',
      description: 'Content page'
    )

    training_module.fields.create(id: 'title', name: 'Title', required: true, type: 'Symbol')
    training_module.fields.create(id: 'depends_on', name: 'Depends on training module', type: 'Link', link_type: 'Entry', link_content_type: 'module')
    training_module.fields.create(id: 'name', name: 'Name', required: true, type: 'Symbol')
    training_module.fields.create(id: 'thumbnail', name: 'Thumbnail', type: 'Link', link_type: 'Asset', link_mimetype_group: ['image'])
    training_module.fields.create(id: 'short_description', name: 'Short description', required: false, type: 'Text')
    training_module.fields.create(id: 'description', name: 'Description', required: true, type: 'Text')
    training_module.fields.create(id: 'objective', name: 'Objective', required: true, type: 'Text')
    training_module.fields.create(id: 'criteria', name: 'Criteria', required: true, type: 'Text')
    training_module.fields.create(id: 'duration', name: 'Duration', required: true, type: 'Number')
    training_module.fields.create(id: 'summative_threshold', name: 'Summative threshold', required: false, type: 'Number', default_value: 70)
    training_module.fields.create(id: 'content_pages', name: 'Content pages', required: false, type: 'Link', link_content_type: 'page')
    training_module.update(displayField: 'title')

    #item_page.fields.create(id: 'training_module', name: 'Training module', type: 'Link', link_type: 'Entry', link_content_type: 'module')
    item_page.fields.create(id: 'name', name: 'Name', required: true, type: 'Symbol')
    item_page.fields.create(id: 'heading', name: 'Heading', type: 'Symbol')
    item_page.fields.create(id: 'type', name: 'Type', required: true, type: 'Symbol')
    item_page.fields.create(id: 'body', name: 'Body', type: 'Text')
    item_page.fields.create(id: 'notes', name: 'Notes', type: 'Boolean', default_value: false)
    item_page.update(displayField: 'name')
  
    training_module.activate
    item_page.activate

    TrainingModule.all.each do |tm|
      log "creating #{tm.name}"

      module_entry = training_module.entries.create(
        id: tm.id,
        title: tm.title,
        name: tm.name,
        short_description: tm.short_description,
        description: tm.description,
        objective: tm.objective,
        criteria: tm.criteria,
        duration: tm.duration,
        summative_threshold: tm.summative_threshold
      )

      tm.module_items.each do |item|
        item_page_entry = item_page.entries.create(
          id: item.id,
          name: item.name,
          type: item.type,
          heading: item.model&.heading,
          body: item.model&.body,
          notes: item.model&.notes
        )
      end
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
