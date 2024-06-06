class CreateMailEvent < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :template
      t.jsonb :personalisation
      t.jsonb :callback

      t.timestamps
    end
  end
end
