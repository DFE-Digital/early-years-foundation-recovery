module UserHelper
  # @return [String, nil]
  def early_years_experience_patch
    old_data = Trainee::Experience.all.find do |exp|
      exp.id.eql?(current_user.early_years_experience)
    end

    old_data&.name || current_user.early_years_experience
  end
end
