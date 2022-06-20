class AddSummativeAssessmentFieldsToUserAnswers < ActiveRecord::Migration[7.0]
  def up
    add_column :user_answers, :module, :string
    add_column :user_answers, :name, :string
    add_column :user_answers, :assessments_type, :string
  end
  def down
    remove_column :user_answers, :module
    remove_column :user_answers, :name
    remove_column :user_answers, :assessments_type
  end
end
