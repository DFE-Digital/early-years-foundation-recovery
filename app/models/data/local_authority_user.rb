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
        all_users_count.each do |local_authority, count|
          complete_count = registration_complete_count[local_authority].to_i
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
    def all_users_count
      count_by_local_authority(filter_users)
    end

    # @return [Hash{Symbol=>Integer}]
    def registration_complete_count
      count_by_local_authority(User.registration_complete)
    end

    # @return [ActiveRecord::Relation<User>] Users created after public beta launch with non-nil local authorities
    def filter_users
      User.public_beta.local_authority_present
    end
  end
end
