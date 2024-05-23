# Simple background job using a dummy template
class TestBulkMailJob < MailJob
  def run
    expire if Rails.application.live?

    super do
      self.class.recipients.find_each do |recipient|
        recipient.test_email

        # TODO: user record log of mail activity?
        # recipient.update!(notify_log:)
        # where("notify_callback -> 'template_id' ?", template_id)
      end
    end

    private

    # @return [String]
    def template_id
      NotifyMailer::TEMPLATE_IDS[:bulk_test]
    end
  end
end
