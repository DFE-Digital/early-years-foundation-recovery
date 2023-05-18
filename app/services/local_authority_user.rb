class LocalAuthorityUser
  include ToCsv

  # @return [String]
  def self.to_csv
    all_users, registration_complete = get_local_auth_data
    CSV.generate do |csv|
      csv << ['Local Authority', 'Total Users', 'Registration Completed']
      all_users.each do |local_authority, count|
        complete_count = registration_complete[local_authority].to_i
        csv << [local_authority, count, complete_count]
      end
    end
  end

  # @param users [ActiveRecord::Relation]
  # @return [Hash]
  def self.count_by_local_authority(users)
    users.group(:local_authority).count
  end

  # @return [Array<Hash>]
  def self.get_local_auth_data
    all_users = count_by_local_authority(post_public_beta)
    registration_complete = count_by_local_authority(User.registration_complete)
    [all_users, registration_complete]
  end

  # @return [ActiveRecord::Relation] Users created after public beta launch
  def self.post_public_beta
    User.where(created_at: Time.zone.local(2023, 2, 9, 15, 0, 0)..Time.zone.now)
    .where.not(local_authority: nil)
  end
end
