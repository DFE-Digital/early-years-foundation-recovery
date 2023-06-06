class AddTrainingEmailPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :training_email_opt_in, :boolean
  end
end
