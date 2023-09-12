class PopulateLastLoggedInAtJob < ApplicationJob
  def run
    super do
      update_last_logged_in_at
    end
  end

  def update_last_logged_in_at
    User.find_in_batches(batch_size: 1000) do |users|
      users.each do |user|
        break unless user.last_logged_in_at.nil?

        last_visit = Ahoy::Visit.where(user_id: user.id).order(started_at: :desc).first
        user.update!(last_logged_in_at: last_visit.started_at) if last_visit
      end
    end
  end
end
