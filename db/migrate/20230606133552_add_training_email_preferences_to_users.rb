class AddTrainingEmailPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :training_emails, :boolean
  end
end
