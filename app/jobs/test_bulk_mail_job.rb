# Simple background job using a dummy template
class TestBulkMailJob < MailJob
  # @note guard clause prevents testing against production data
  #
  def run
    expire if Rails.application.live?

    super do
      self.class.recipients.find_each do |user|
        prepare_message(user)
      end
    end
  end
end
