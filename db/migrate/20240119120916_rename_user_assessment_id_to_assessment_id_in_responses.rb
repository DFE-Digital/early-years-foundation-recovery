class RenameUserAssessmentIdToAssessmentIdInResponses < ActiveRecord::Migration[7.0]
  def change
    remove_column :responses, :user_assessment_id, :integer
    add_reference :responses, :assessment, foreign_key: true, null: true
  end
end
