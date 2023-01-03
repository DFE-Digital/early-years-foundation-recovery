class Upload
  require 'contentful/management'

  attr_reader :module_id, :space, :token, :environment, :client

  def initialize(module_id:)
    @module_id = module_id
    @space = Rails.application.credentials.dig(:contentful, :space)
    @token = Rails.application.credentials.dig(:contentful, :management_access_token)
    @environment = 'development'
    @client = Contentful::Management::Client.new(token)
  end

  def call
    log client.configuration
    log "space: #{space}"

    ct_module = client.content_types(space, environment).find('module')
    #ct_module.activate

    ct_page = client.content_types(space, environment).find('page')
    #ct_page.activate

    ct_question = client.content_types(space, environment).find('question')
    #ct_question.activate

    ct_confidence = client.content_types(space, environment).find('confidence')
    #ct_confidence.activate

    tm = TrainingModule.find_by(name: module_id)

    if tm.present?
      log "creating #{tm.name}"

      module_entry = ct_module.entries.create(
        title: tm.title,
        slug: tm.name,
        short_description: tm.short_description,
        description: tm.description,
        duration: tm.duration,
        summative_threshold: tm.summative_threshold,
      )
      log "module entry #{module_entry.title}"

      pages = tm.module_items.map do |item|
        ct_page.entries.create(
          heading: item.model&.heading(remote: false),
          module_id: tm.name,
          slug: item.name,
          component: item.type,
          body: item.model&.body(remote: false),
          notes: item.model&.notes?(remote: false),
        )
      end

      module_entry.pages = pages

      formative_questions = FormativeQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        ct_question.entries.create(
          slug: q.name,
          module_id: q.training_module,
          component: 'formative_assessment',
          body: question[:body],
          multi_select: question[:multi_select],
          assessment_summary: question[:assessment_summary],
          assessment_fail_summary: question[:assessment_fail_summary],
          answers: question[:answers],
          correct_answers: question[:correct_answers],
        )
      end

      summative_questions = SummativeQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        ct_question.entries.create(
          slug: q.name,
          module_id: q.training_module,
          component: 'summative_assessment',
          body: question[:label],
          multi_select: question[:multi_select],
          assessment_summary: question[:assessment_summary],
          assessment_fail_summary: question[:assessment_fail_summary],
          answers: question[:answers],
          correct_answers: question[:correct_answers],
        )
      end

      confidence = ConfidenceQuestionnaire.where(training_module: tm.name).map do |q|
        questionnaire_name, question = q.questions.first
        ct_confidence.entries.create(
          body: question[:label],
          slug: q.name,
          module_id: q.training_module,
          component: 'confidence_check',
          answers: { 1 => 'Strongly agree', 2 => 'Agree', 3 => 'Neither agree nor disagree', 4 => 'Disagree', 5 => 'Strongly disagree', },
          correct_answers: [1,2,3,4,5],
        )
      end

      log "finish #{tm.name}"
    else
      log(tm.name + " not found")
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