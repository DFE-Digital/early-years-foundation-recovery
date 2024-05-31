class MailEvent < ApplicationRecord
  belongs_to :user

  scope :newest_module, -> { where(template: NewModuleMailJob.template_id).where('personalisation @> ?', { mod_number: Training::Module.live.last.position }.to_json) }
end
