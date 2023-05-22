module Data
  class LocalAuthorityUser
    include ToCsv

    def self.to_csv
      new.generate_csv
    end

    # @return [String]
    def generate_csv
      CSV.generate do |csv|
        csv << ['Local Authority', 'Total Users', 'Registration Completed']
        public_beta_user_count.each do |local_authority, count|
          complete_count = active_user_count[local_authority].to_i
          csv << [local_authority, count, complete_count]
        end
      end
    end

  private

    # @param users [ActiveRecord::Relation<User>]
    # @return [Hash{Symbol=>Integer}]
    def count_by_local_authority(users)
      users.group(:local_authority).count
    end

    # @return [Hash{Symbol=>Integer}]
    def active_user_count
      count_by_local_authority(User.since_public_beta.registration_complete)
    end

    # @return [Hash{Symbol=>Integer}]
    def public_beta_user_count
      count_by_local_authority(public_beta_users)
    end

    # @return [ActiveRecord::Relation<User>]
    def public_beta_users
      User.since_public_beta.with_local_authority
    end
  end
end
