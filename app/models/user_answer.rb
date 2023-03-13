class UserAnswer < ApplicationRecord
  include ToCsv

  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user

  # @return [Questionnaire]
  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(training_module: self.module, name: name)
  end

  serialize :answer, Array

  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }
end
