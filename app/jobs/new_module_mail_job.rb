# @see ReleaseController#new
#
# Record module publications and queue requested release emails.
class NewModuleMailJob < MailJob
  self.maximum_retry_count = 0

  # @param release_id [Integer]
  def run(release_id)
    super do
      log "cache key #{Training::Module.cache_key}"
      log 'recalculating key...'
      Training::Module.reset_cache_key!
      log "cache key #{Training::Module.cache_key}"

      begin
        release = Release.find(release_id)
      rescue ActiveRecord::RecordNotFound
        return :no_new_module_release if release.blank?
      end

      Training::Module.live.each do |mod|
        module_release = record_module_release(mod, release)
        next unless mod.release_email_requested?

        module_release.with_lock do
          next if module_release.release_email_queued_at.present?

          recipients = self.class.recipients(mod.id)
          log "#{recipients.count} recipients for module #{mod.id}"

          recipients.find_each do |user|
            prepare_message(user, mod)
          end

          module_release.update!(release_email_queued_at: Time.current)
        end
      end
    end
  end

private

  # @param mod [Training::Module]
  # @param release [Release]
  # @return [ModuleRelease]
  def record_module_release(mod, release)
    ModuleRelease.find_or_create_by!(contentful_entry_id: mod.id) do |record|
      record.release_id = release.id
      record.module_position = mod.position
      record.name = mod.name
      record.first_published_at = release.time
    end
  end

  def log_recipient_count
    # Recipient counts are logged per module in run.
  end
end
