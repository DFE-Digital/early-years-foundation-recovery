class AddUserAssessmentFieldsToUserAnswers < ActiveRecord::Migration[7.0]
  def change
    change_table :user_answers do |t|
      t.references :user_assessment, null: true, foreign_key: true
    end
  end

  def down
    remove_column :user_answers, :user_assessment_id
  end
end
