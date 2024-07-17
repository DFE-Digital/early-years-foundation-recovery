class DropUserAssessmentsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_assessments
  end
end
