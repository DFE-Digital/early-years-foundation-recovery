class UserAnswer < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include ContentfulWrapper

  belongs_to :user

  # @return [Questionnaire]
  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(training_module: self.module, name: name)
  end

  serialize :answer, Array

  def training_module
    self.module
  end

  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }
end
