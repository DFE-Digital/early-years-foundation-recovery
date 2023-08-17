class NewModuleMailJob < ScheduledJob
  def run
    return if new_module.nil?

    notify_users(new_module)
    create_published_record(new_module)
  end

private

  def create_published_record(mod)
    PreviouslyPublishedModule.create!(module_position: mod.position, name: mod.name, first_published_at: mod.published_at)
  end

  def notify_users(mod)
    mail_service = NudgeMail.new
    mail_service.new_module(mod)
  end

  def new_module
    latest_published = Training::Module.ordered.reject(&:draft?).last
    if latest_published.position == PreviouslyPublishedModule.ordered.last.module_position
      nil
    else
      Training::Module.ordered.reject(&:draft?).last
    end
  end
end
