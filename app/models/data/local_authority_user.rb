module Data
  class LocalAuthorityUser
    include ToCsv

    def self.to_csv
      new.generate_csv
    end

    # @return [String]
    def generate_csv
      CSV.generate do |csv|
        csv << ['Local Authority', 'Users']
        count_by_local_authority.each do |local_authority, count|
          csv << [local_authority, count]
        end
      end
    end

  private

    # @param users [ActiveRecord::Relation<User>]
    # @return [Hash{Symbol=>Integer}]
    def count_by_local_authority
      public_beta_users.group(:local_authority).count
    end

    # @return [ActiveRecord::Relation<User>]
    def public_beta_users
      User.since_public_beta.with_local_authority
    end
  end
end
