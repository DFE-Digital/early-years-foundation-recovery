class Data::LocalAuthorityUser
  include ToCsv

  def self.to_csv
    new.generate_csv
  end

  # @return [String]
  def generate_csv
    all_users, registration_complete = retrieve_local_auth_data
    CSV.generate do |csv|
      csv << ['Local Authority', 'Total Users', 'Registration Completed']
      all_users.each do |local_authority, count|
        complete_count = registration_complete[local_authority].to_i
        csv << [local_authority, count, complete_count]
      end
    end
  end

private

  # @param users [ActiveRecord::Relation]
  # @return [Hash] Hash of local authorities and their corresponding counts
  def count_by_local_authority(users)
    users.group(:local_authority).count
  end

  # @return [Array<Hash>]
  def retrieve_local_auth_data
    all_users = count_by_local_authority(filter_users)
    registration_complete = count_by_local_authority(User.registration_complete)
    [all_users, registration_complete]
  end

  # @return [ActiveRecord::Relation] Users created after public beta launch with non-nil LAs
  def filter_users
    User.where(created_at: public_beta_launch..Time.zone.now)
    .where.not(local_authority: nil)
  end

  # @return [ActiveSupport::TimeWithZone]
  def public_beta_launch
    Time.zone.local(2023, 2, 9, 15, 0, 0)
  end
end
