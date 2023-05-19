class Data::LocalAuthorityUser
  include ToCsv

  def self.to_csv
    new.generate_csv
  end

  # @return [String]
  def generate_csv
    CSV.generate do |csv|
      csv << ['Local Authority', 'Total Users', 'Registration Completed']
      all_users_count.each do |local_authority, count|
        complete_count = registration_complete_count[local_authority].to_i
        csv << [local_authority, count, complete_count]
      end
    end
  end

private

  # @param users [ActiveRecord::Relation]
  # @return [Hash{Symbol=>Integer}]
  def count_by_local_authority(users)
    users.group(:local_authority).count
  end

  # @return [Hash{Symbol=>Integer}]
  def all_users_count
    count_by_local_authority(filter_users)
  end

  # @return [Hash{Symbol=>Integer}]
  def registration_complete_count
    count_by_local_authority(User.registration_complete)
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
