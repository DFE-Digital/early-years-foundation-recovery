class UserAnswer < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :questionnaire_data, foreign_key: :questionnaire_id
  belongs_to :summative_questionnaire, foreign_key: :questionnaire_id

  def questionnaire
    @questionnaire ||= questionnaire_data.build_questionnaire
  end

  def questionnaire_summative
    @questionnaire_summative ||= summative_questionnaire.build_questionnaire
  end

  def questionnaire_summative_answers
    
  end

  serialize :answer, Array

  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }
end
