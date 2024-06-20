# Sends mail for continue training for a module
# @note This queues up this job unless stated otherwise
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
