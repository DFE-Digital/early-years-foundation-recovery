module Data
  class LocalAuthorityUser
    include ToCsv

    # @return [String]
    def self.column_names
      ['Local Authority', 'Users']
    end

    # @return [Array<Hash{Symbol => Mixed}>]
    def self.dashboard
      data = []
      count_by_local_authority.each do |authority, count|
        row = {
          local_authority: authority,
          users: count,
        }
        data << row
      end
      data
    end

    # @return [Hash{Symbol=>Integer}]
    def self.count_by_local_authority
      public_beta_users.group(:local_authority).count
    end

    # @return [ActiveRecord::Relation<User>]
    def self.public_beta_users
      User.since_public_beta.with_local_authority
    end
  end
end
