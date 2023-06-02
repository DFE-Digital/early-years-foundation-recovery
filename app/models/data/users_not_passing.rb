module Data 
    class UsersNotPassing 
        
        
        
        def self.to_csv
            headers = ['Module', 'Total Users Not Passing']
            data = new.total_users_not_passing_per_module.map { |module_name, total_users| [module_name, total_users] }
            CSV.generate do |csv|
                csv << headers
        
                data.each do |row|
                  csv << row
                end
              end
    
          end

              def total_users_not_passing_per_module
                UserAssessment.summative
                  .group(:module, :user_id)
                  .count
                  .reject { |(module_name, user_id), _| UserAssessment.summative.where(module: module_name, user_id: user_id).passes.exists? }
                  .group_by { |(module_name, _), _| module_name }
                  .transform_values(&:size)
              end
    end
end
