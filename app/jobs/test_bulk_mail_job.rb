# Simple background job using a dummy template
class TestBulkMailJob < MailJob
  # @note guard clause prevents testing against production data
  #
  def run
    expire if Rails.application.live?

    super do
      self.class.recipients.find_each(&:test_email)
    end
  end

  # TODO: user record log of mail activity?
  # recipient.update!(notify_log:)
  # where("notify_callback -> 'template_id' ?", template_id)
  # private

  # @return [String]
  # def template_id
  #   NotifyMailer::TEMPLATE_IDS[:bulk_test]
  # end
end
