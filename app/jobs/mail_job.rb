class MailJob < Que::Job
  def run
    return if queued?

    NudgeMail.new.call
  end

private

  # @return [Boolean]
  def queued?
    Que.job_stats.any? { |job| job[:job_class] == 'MailJob' && job[:count] > 1 }
  end
end
