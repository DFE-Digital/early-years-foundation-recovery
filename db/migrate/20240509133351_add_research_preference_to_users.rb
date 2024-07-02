class AddResearchPreferenceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :research_participant, :boolean
  end
end
