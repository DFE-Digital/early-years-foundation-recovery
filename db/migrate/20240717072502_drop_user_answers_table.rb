class DropUserAnswersTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_answers
  end
end
