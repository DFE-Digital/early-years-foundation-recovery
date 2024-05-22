# Simple background job using a dummy template
class TestBulkMailJob < MailJob
  def run
    expire if Rails.application.live?

    super do
      self.class.recipients.find_each do |recipient|
        recipient.send_devise_notification(:bulk_test)

        # TODO: user record log of mail activity?
        # recipient.update!(notify_log:)
      end
    end
  end
end
