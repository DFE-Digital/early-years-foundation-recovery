class Upload
  require 'contentful/management'

  def self.call(module_id)
    new(module_id: module_id).call
  end

  attr_reader :module_id, :space, :token, :environment, :client

  def initialize(module_id:)
    @module_id = module_id
    @space = ContentfulRails.configuration.space
    @token = ContentfulRails.configuration.management_token
    @environment = ContentfulRails.configuration.environment
    @client = Contentful::Management::Client.new(token)
  end

  def call
    log client.configuration
    log "space: #{space}"

    ct_module = client.content_types(space, environment).find('trainingModule')
    ct_page = client.content_types(space, environment).find('page')
    ct_question = client.content_types(space, environment).find('question')
    ct_video = client.content_types(space, environment).find('video')

    tm = TrainingModule.find_by(name: module_id)

    if tm.present?
      log "creating #{tm.name}"

      module_entry = ct_module.entries.create(
        title: tm.title,
        name: tm.name,
        short_description: tm.short_description,
        description: tm.description,
        duration: tm.duration,
        summative_threshold: tm.summative_threshold,
        objective: tm.objective,
        criteria: tm.criteria
      )
      log "module entry #{module_entry.title}"

      pages = tm.module_items.map do |item|
        case item.type
        when /video_page/
          entry = item.model
          ct_video.entries.create(
            name: item.name,
            trainingModule: tm.name,
            transcript: entry.transcript,
            title: entry.translate(:video)[:title],
            videoId: entry.translate(:video)[:id].to_s,
            videoProvider: entry.translate(:video)[:provider]
          )
        when /formative_questionnaire/
          questionnaire = FormativeQuestionnaire.where(training_module: tm.name, name: item.name).first
          questionnaire_name, question = questionnaire[:questions].first
          answers = question[:answers].map{|key,value| {key => [value, question[:correct_answers].include?(key)]} }
          ct_question.entries.create(
            name: questionnaire.name,
            trainingModule: questionnaire.training_module,
            body: question[:body],
            assessmentSucceed: question[:assessment_summary],
            assessmentFail: question[:assessment_fail_summary],
            assessmentsType: question[:assessments_type],
            answers: answers,
            pageNumber: questionnaire.page_number,
            totalQuestions: questionnaire.total_questions
          )
        when /confidence_questionnaire/
          questionnaire = ConfidenceQuestionnaire.where(training_module: tm.name, name: item.name).first
          questionnaire_name, question = questionnaire[:questions].first
          answers = question[:answers].map{|key,value| {key => [value, question[:correct_answers].include?(key)]} }
          ct_question.entries.create(
            name: questionnaire.name,
            trainingModule: questionnaire.training_module,
            body: question[:body],
            assessmentSucceed: question[:assessment_summary],
            assessmentFail: question[:assessment_fail_summary],
            assessmentsType: question[:assessments_type],
            answers: answers,
            pageNumber: questionnaire.page_number,
            totalQuestions: questionnaire.total_questions
          )
        when /summative_questionnaire/
          questionnaire = SummativeQuestionnaire.where(training_module: tm.name, name: item.name).first
          questionnaire_name, question = questionnaire[:questions].first
          answers = question[:answers].map{|key,value| {key => [value, question[:correct_answers].include?(key)]} }
          ct_question.entries.create(
            name: questionnaire.name,
            trainingModule: questionnaire.training_module,
            body: question[:body],
            assessmentSucceed: question[:assessment_summary],
            assessmentFail: question[:assessment_fail_summary],
            assessmentsType: question[:assessments_type],
            answers: answers,
            pageNumber: questionnaire.page_number,
            totalQuestions: questionnaire.total_questions
          )
        else 
          ct_page.entries.create(
            name: item.name,
            heading: item.model&.heading,
            trainingModule: tm.name,
            pageType: item.type,
            body: item.model&.body,
            notes: item.model&.notes?
          )
        end
      end
      module_entry.pages = pages
      module_entry.save

      log "finish #{tm.name}"
    else
      log("#{tm.name} not found")
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
