# Sends mail for continue training for a module
# @note email delivery is queued unless DELIVERY_QUEUE=false
class ContinueTrainingMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        user.modules_in_progress.each do |mod_name|
          mod = Training::Module.by_name(mod_name)
          prepare_message(user, mod)
        end
      end
    end
  end
end
