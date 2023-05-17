class LocalAuthorityUser
    include ToCsv

    def self.group_by_local_authority
        post_public_beta = User.where(created_at: DateTime.new(2023, 2, 9, 15, 0, 0)..DateTime.now).where.not(local_authority: nil)
        all_users = post_public_beta.group(:local_authority).count
        registration_complete = User.registration_complete.group(:local_authority).count
        [all_users, registration_complete]
    end
  
    def self.to_csv
        all_users, registration_complete = self.group_by_local_authority
        csv_data = CSV.generate do |csv|
          csv << ['Local Authority', 'Total Users', 'Registration Completed']
          all_users.each do |local_authority, count|
            complete_count = registration_complete[local_authority]
            csv << [local_authority, count, complete_count]
          end
        end
        csv_data
      end
    end