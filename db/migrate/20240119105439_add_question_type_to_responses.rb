class AddQuestionTypeToResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :responses, :question_type, :string
  end
end
