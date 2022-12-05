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

    ct_module = client.content_types(space, 'master').find('module')
    ct_module.activate

    ct_page = client.content_types(space, 'master').find('page')
    ct_page.activate
    
    ct_question = client.content_types(space, 'master').find('question')
    ct_question.activate
    
    ct_answer = client.content_types(space, 'master').find('answer')
    ct_answer.activate
    
    ct_confidence = client.content_types(space, 'master').find('confidence')
    ct_confidence.activate
    
    TrainingModule.all.each do |tm|
      log "creating #{tm.name}"

      module_entry = ct_module.entries.create(
        title: tm.title,
        id: tm.id,
        slug: tm.name,
        short_description: tm.short_description,
        description: tm.description,
        duration: tm.duration,
        summative_threshold: tm.summative_threshold
      )
      log "module entry #{module_entry.title}"

      pages = tm.module_items.map do |item|
        ct_page.entries.create(
          heading: item.model&.heading,
          module_id: tm.name,
          slug: item.name,
          component: item.type,
          body: item.model&.body,
          notes: item.model&.notes
        )
      end

      module_entry.pages = pages
      module_entry.save
      
      formative_questions = FormativeQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        answers = question[:answers].map do |answer_id, answer_text|
          ct_answer.entries.create(body: answer_text, correct: question[:correct_answers].include?(answer_id))
        end
        ct_question.entries.create(
          id: questionnaire_name,
          slug: q.name,
          module_id: q.training_module,
          component: 'formative',
          body: question[:body],
          multi_select: question[:multi_select],
          assessment_summary: question[:assessment_summary],
          assessment_fail_summary: question[:assessment_fail_summary],
          answers: answers
        )
      end

      summative_questions = SummativeQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        answers = question[:answers].map do |answer_id, answer_text|
          ct_answer.entries.create(body: answer_text, correct: question[:correct_answers].include?(answer_id))
        end
        ct_question.entries.create(
          id: questionnaire_name,
          slug: q.name,
          module_id: q.training_module,
          component: 'summative',
          body: question[:label],
          multi_select: question[:multi_select],
          assessment_summary: question[:assessment_summary],
          assessment_fail_summary: question[:assessment_fail_summary],
          answers: answers
        )
      end

      confidence = ConfidenceQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        ct_confidence.entries.create(
          body: question[:label],
          id: questionnaire_name,
          slug: q.name,
          module_id: q.training_module
        )
      end

      log "finish #{tm.name}"
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
