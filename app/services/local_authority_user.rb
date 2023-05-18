class LocalAuthorityUser
  include ToCsv

  def group_by_local_authority
    post_public_beta = User.where(created_at: Time.zone.local(2023, 2, 9, 15, 0, 0)..Time.zone.now).where.not(local_authority: nil)
    all_users = post_public_beta.group(:local_authority).count
    registration_complete = User.registration_complete.group(:local_authority).count
    [all_users, registration_complete]
  end

  def to_csv
    all_users, registration_complete = group_by_local_authority
    CSV.generate do |csv|
      csv << ['Local Authority', 'Total Users', 'Registration Completed']
      all_users.each do |local_authority, count|
        complete_count = registration_complete[local_authority].to_i
        csv << [local_authority, count, complete_count]
      end
    end
  end
end
