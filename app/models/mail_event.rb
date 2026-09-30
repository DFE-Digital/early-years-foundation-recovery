class MailEvent < ApplicationRecord
  belongs_to :user

  scope :for_module_release_email, lambda { |contentful_entry_id|
    where(template: NewModuleMailJob.template_id)
      .where(
        'personalisation @> ?',
        { contentful_entry_id: contentful_entry_id }.to_json,
      )
  }
end
