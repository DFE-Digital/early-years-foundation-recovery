# Sends mail for continue training for a module
# @note email delivery is queued unless DELIVERY_QUEUE=false
class ContinueTrainingMailJob < MailJob
  def run
    super do
      Training::Module.live.each do |mod|
        recipients = self.class.recipients(mod.id)
          .where(
            id: UserModuleProgress.in_progress
              .where(module_name: mod.name)
              .select(:user_id),
          )

        log "#{recipients.count} recipients for module #{mod.id}"

        recipients.find_each do |user|
          prepare_message(user, mod)
        end
      end
    end
  end

private

  def log_recipient_count
    # Recipient counts are logged per module in run
  end
end
